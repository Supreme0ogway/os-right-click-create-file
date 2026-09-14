import AppKit
import FinderSync
import RightClickMenuCore
import UniformTypeIdentifiers
import os

/// The part of the app that lives inside the Finder.
///
/// It does three things and no more: say which folders it watches, hand back the menu
/// it is told to show, and pass a click on to the app. Every decision behind those
/// answers is worked out in the module it imports, where it can be tested without a
/// Finder to click in.
///
/// The menu is one entry with the file types hanging off it, so the Finder's own menu
/// gains a single line however many types somebody has. Each type carries the icon the
/// mac already uses for that extension.
///
/// It runs in a sandbox and is not allowed to write files, which is why a click is
/// forwarded to the app rather than acted on here.
///
/// - Note: A menu handed to the Finder is packed up and sent to another process, and
///   only the plain parts of an entry survive that trip. Anything hung on an entry as
///   an object arrives as nothing, so which type was clicked travels as a number.
///
/// - Note: The folder that was clicked can only be asked for while the menu is being
///   built or inside the action it made. Asking later, or after any hop off this
///   thread, answers nothing.
final class FinderMenuExtension: FIFinderSync {

    private let log = Logger(
        subsystem: BundleConstants.appIdentifier,
        category: ExtensionConstantsLog.category
    )

    private var lastMenuKind: FIMenuKind = .contextualMenuForItems

    override init() {
        super.init()
        refreshWatchedFolders()
        log.info("started")
    }

    // MARK: - What the Finder asks for

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        lastMenuKind = menuKind

        let legend = readLegend()
        guard MenuPlan.hasAnythingToShow(legend) else {
            log.info("no types, showing no menu")
            return nil
        }

        let flyout = NSMenu(title: MenuPlan.parentTitle)
        for entry in MenuPlan.entries(for: legend) {
            flyout.addItem(item(for: entry, in: legend))
        }

        let parent = NSMenuItem(title: MenuPlan.parentTitle, action: nil, keyEquivalent: "")
        parent.submenu = flyout

        let menu = NSMenu(title: "")
        menu.addItem(parent)
        log.info("built \(flyout.numberOfItems) entries for kind \(menuKind.rawValue)")
        return menu
    }

    private func item(for entry: MenuEntry, in legend: Legend) -> NSMenuItem {
        let item = NSMenuItem(
            title: entry.title,
            action: #selector(createFile(_:)),
            keyEquivalent: ""
        )
        item.target = self
        item.tag = entry.place
        item.image = icon(for: legend.type(withId: entry.typeId)?.fileExtension)
        return item
    }

    private func icon(for fileExtension: String?) -> NSImage {
        let type = fileExtension.flatMap { UTType(filenameExtension: $0) } ?? .data
        let image = NSWorkspace.shared.icon(for: type)
        image.size = NSSize(width: MenuIconSize.side, height: MenuIconSize.side)
        return image
    }

    override func beginObservingDirectory(at url: URL) {
        refreshWatchedFolders()
    }

    // MARK: - What a click does

    @objc private func createFile(_ sender: NSMenuItem) {
        guard let entry = MenuPlan.entry(at: sender.tag, in: readLegend()) else {
            leaveNote("", folder: "", handedOver: false, note: ExtensionNote.noType)
            return
        }
        let typeText = entry.typeId.text

        guard let folder = targetFolder() else {
            leaveNote(typeText, folder: "", handedOver: false, note: ExtensionNote.noFolder)
            return
        }

        let request = CreateRequest(typeId: entry.typeId, folderPath: folder.path)
        let opened = NSWorkspace.shared.open(request.url)
        leaveNote(
            typeText,
            folder: folder.path,
            handedOver: opened,
            note: opened ? "" : ExtensionNote.notOpened
        )
    }

    private func leaveNote(_ typeText: String, folder: String, handedOver: Bool, note: String) {
        RequestTrail(
            typeId: typeText,
            folderPath: folder,
            menuKind: Int(lastMenuKind.rawValue),
            handedOver: handedOver,
            note: note
        ).record()
        log.info("\(typeText, privacy: .public) handedOver=\(handedOver)")
    }

    private func targetFolder() -> URL? {
        let controller = FIFinderSyncController.default()
        guard lastMenuKind == .contextualMenuForItems else { return controller.targetedURL() }
        guard let clicked = controller.selectedItemURLs()?.first else {
            return controller.targetedURL()
        }
        return folderHolding(clicked)
    }

    private func folderHolding(_ url: URL) -> URL {
        let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
        guard values?.isDirectory == true else { return url.deletingLastPathComponent() }
        return url
    }

    // MARK: - Reading what the app saved

    private func readLegend() -> Legend {
        guard let fileURL = SharedContainer.legendFileURL else {
            log.error("no shared folder, so no types to show")
            return .empty
        }
        return RecordFile.read(from: fileURL, fallback: .empty)
    }

    private func readScope() -> Scope {
        guard let fileURL = SharedContainer.scopeFileURL else { return .fallback }
        return RecordFile.read(from: fileURL, fallback: .fallback)
    }

    private func refreshWatchedFolders() {
        let folders = WatchList.folderURLs(for: readScope())
        FIFinderSyncController.default().directoryURLs = folders
        log.info("watching \(folders.count) folders")
    }
}

/// How big the icon beside each entry is drawn.
enum MenuIconSize {

    /// The side of the square an icon is drawn in, in points.
    static let side: CGFloat = 16
}

/// Where this extension's messages are filed.
enum ExtensionConstantsLog {

    /// The category every message from the Finder extension carries.
    static let category = "finder-extension"
}

/// What the extension writes down when a click does not reach the app.
enum ExtensionNote {

    /// The clicked entry pointed at a type the list no longer holds.
    static let noType = "the clicked entry pointed at no type"

    /// The Finder would not say which folder was clicked.
    static let noFolder = "the Finder named no folder"

    /// The app could not be asked to make the file.
    static let notOpened = "the app could not be opened"
}
