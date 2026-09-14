import AppKit
import RightClickMenuCore
import os

/// What the app does when the Finder extension asks it for a file.
///
/// The extension cannot write anything itself, so every click in the right click menu
/// arrives here as an address. This reads it, makes the file, and shows the result in
/// the Finder so the user can see what just happened.
///
/// A refused write is said out loud rather than swallowed: a menu that appears to do
/// nothing is worse than one that explains itself.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    /// The stores, made once when the app starts.
    let services = AppServices()

    /// The one window, made once and kept.
    lazy var editor = EditorWindow(services: services)

    private let log = Logger(subsystem: BundleConstants.appIdentifier, category: "app")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let key = NSApplication.launchIsDefaultUserInfoKey
        let openedByHand = notification.userInfo?[key] as? Bool ?? true
        guard openedByHand else { return }
        editor.show()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        guard !hasVisibleWindows else { return true }
        editor.show()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            handle(url)
        }
    }

    private func handle(_ url: URL) {
        log.info("opened with \(url.absoluteString, privacy: .public)")
        guard let request = CreateRequest(url: url) else {
            report(AppText.requestNotUnderstood)
            return
        }
        create(request)
    }

    private func create(_ request: CreateRequest) {
        services.legend.reload()
        guard let type = services.legend.value.type(withId: request.typeId) else {
            report(AppText.typeNoLongerExists)
            return
        }

        do {
            let written = try FileWriter().createFile(
                ofType: type,
                in: URL(filePath: request.folderPath)
            )
            log.info("wrote \(written.path, privacy: .public)")
            NSWorkspace.shared.activateFileViewerSelecting([written])
        } catch {
            report(AppText.couldNotWrite(error))
        }
    }

    private func report(_ message: String) {
        let alert = NSAlert()
        alert.messageText = AppText.couldNotMakeFile
        alert.informativeText = message
        alert.alertStyle = .warning
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
