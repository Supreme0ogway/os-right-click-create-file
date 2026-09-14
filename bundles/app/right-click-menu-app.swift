import FinderSync
import SwiftUI

/// Where the app starts.
///
/// There is no window and no dock icon. The app is an icon in the menu bar that keeps
/// the file types, answers the Finder extension, and otherwise stays out of the way.
/// Because there is no dock icon there is no other way to close it, so the menu always
/// offers a way out.
@main
struct RightClickMenuApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenu(services: delegate.services, editor: delegate.editor)
        } label: {
            Image(systemName: MenuBarConstants.iconName)
                .renderingMode(.template)
                .symbolRenderingMode(.monochrome)
                .accessibilityLabel(AppText.menuTitle)
        }
        .menuBarExtraStyle(.menu)
    }
}

/// Fixed facts about the menu bar item.
enum MenuBarConstants {

    /// The system icon shown in the menu bar.
    ///
    /// A system symbol rather than a picture of our own, so the menu bar draws it at
    /// whatever size and sharpness the screen needs and follows light and dark of its
    /// own accord. A fixed picture is what looks soft on a retina screen.
    static let iconName = "doc.badge.plus"
}
