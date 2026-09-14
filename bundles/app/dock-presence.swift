import AppKit

/// Whether the app shows up in the dock.
///
/// The app is normally only an icon in the menu bar. While its window is open it is a
/// normal app with a dock icon, so it can be switched to and away from like anything
/// else. Closing the window puts it back in the menu bar rather than closing it, and
/// the only way out is the Quit in the menu bar.
@MainActor
enum DockPresence {

    /// Puts the app in the dock and brings it to the front.
    static func show() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Takes the app out of the dock, leaving it running in the menu bar.
    static func hide() {
        NSApp.setActivationPolicy(.accessory)
    }
}
