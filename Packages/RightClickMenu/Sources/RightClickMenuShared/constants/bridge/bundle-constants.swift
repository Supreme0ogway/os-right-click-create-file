/// Names the app and the Finder extension both have to agree on, letter for letter.
///
/// No team is written down here. The folder the two share is named after whoever
/// signed them, and that is read back off the running bundle, so this source builds
/// for anybody with their own account and nothing to edit.
public enum BundleConstants {

    /// The app's bundle name.
    public static let appIdentifier = "com.willlattus.right-click-menu"

    /// The Finder extension's bundle name. Has to sit under the app's.
    public static let extensionIdentifier = appIdentifier + ".finder-extension"

    /// The middle part of the shared folder's name, between the team and the app.
    public static let appGroupInfix = ".group."

    /// The address that starts the app and asks it for a file.
    public static let urlScheme = "right-click-menu"

    /// The shared folder's name for a given team.
    ///
    /// - Parameter team: The team that signed the bundle.
    /// - Returns: The name the system knows the shared folder by.
    public static func appGroupIdentifier(team: String) -> String {
        team + appGroupInfix + appIdentifier
    }
}
