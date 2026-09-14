import Foundation

/// Every word this app shows a person.
///
/// Kept together and looked up by key, so the wording can be changed or translated
/// without going through the code that shows it.
enum AppText {

    /// Title of the warning shown when a file could not be made.
    static let couldNotMakeFile = String(localized: "app.could-not-make-file")

    /// Shown when the Finder sent an address this app cannot read.
    static let requestNotUnderstood = String(localized: "app.request-not-understood")

    /// Shown when the type was removed between the menu opening and the click.
    static let typeNoLongerExists = String(localized: "app.type-no-longer-exists")

    /// The name the app is known by in the menu bar.
    static let menuTitle = String(localized: "app.menu-title")

    /// Opens the window where file types are added and removed.
    static let editFileTypes = String(localized: "app.edit-file-types")

    /// Closes the app.
    static let quit = String(localized: "app.quit")

    /// Shown when the Finder extension has not been switched on yet.
    static let extensionIsOff = String(localized: "app.extension-is-off")

    /// Shown when the app and the extension cannot share files.
    static let notSharing = String(localized: "app.not-sharing")

    /// Makes the app start when the mac starts.
    static let openAtLogin = String(localized: "app.open-at-login")

    /// Says why the disk refused a write.
    ///
    /// - Parameter error: What the file system threw.
    /// - Returns: The reason, in the user's language where the system gives one.
    static func couldNotWrite(_ error: any Error) -> String {
        String(format: String(localized: "app.could-not-write"), error.localizedDescription)
    }
}
