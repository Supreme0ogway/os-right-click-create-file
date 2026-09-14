import AppKit
import RightClickMenuUI
import SwiftUI

/// The app's one window, and when it is on screen.
///
/// Built by hand rather than left to the scene system, because the dock icon has to
/// come and go with the window and closing it must put the app back in the menu bar
/// instead of ending it.
///
/// The models are made once and kept, so closing the window and opening it again does
/// not start a second reading of the legend or leave the old one listening.
@MainActor
final class EditorWindow: NSObject, NSWindowDelegate {

    private let legend: LegendEditorViewModel
    private let scope: ScopePickerViewModel
    private let transfer: TransferViewModel
    private let preferences: RecordStore<Preferences>
    private let defaultKind: DefaultKindViewModel

    private var window: NSWindow?

    /// Builds the window's models.
    ///
    /// - Parameter services: The stores the screens read and write.
    init(services: AppServices) {
        legend = LegendEditorViewModel(store: services.legend)
        scope = ScopePickerViewModel(store: services.scope)
        transfer = TransferViewModel(store: services.legend)
        preferences = services.preferences
        defaultKind = DefaultKindViewModel(
            known: BuiltInLegend.knownTypes(),
            store: services.preferences
        )
    }

    /// Brings the window up, putting the app in the dock while it is there.
    func show() {
        let window = window ?? makeWindow()
        self.window = window

        DockPresence.show()
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        DockPresence.hide()
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: EditorWindowSize.width,
                height: EditorWindowSize.height
            ),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = AppText.editFileTypes
        window.contentView = NSHostingView(
            rootView: MainWindowView(
                legend: legend,
                scope: scope,
                transfer: transfer,
                preferences: preferences,
                defaultKind: defaultKind,
                version: AppVersion.current
            )
        )
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        window.setFrameAutosaveName(EditorWindowSize.autosaveName)
        ColorDiff.apply(to: window)
        return window
    }
}

/// Which version this build is.
enum AppVersion {

    /// The version the bundle says it is, such as `0.1`.
    static var current: String {
        let key = AboutConstants.versionKey
        let found = Bundle.main.object(forInfoDictionaryKey: key) as? String
        return found ?? AboutConstants.unknownVersion
    }
}

/// How big the window opens, and where its size is remembered.
enum EditorWindowSize {

    /// How wide the window opens the first time.
    static let width: CGFloat = 760

    /// How tall the window opens the first time.
    static let height: CGFloat = 520

    /// The name the window's size and place are remembered under.
    static let autosaveName = "editor"
}
