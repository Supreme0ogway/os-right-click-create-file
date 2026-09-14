/// Fixed facts about the screen that says what the app is and what changed.
public enum AboutConstants {

    /// The name of the shipped list of releases, without its extension.
    public static let changelogResource = "changelog"

    /// What to show as the version when the bundle does not say.
    public static let unknownVersion = "0"

    /// The key a bundle keeps its version under.
    public static let versionKey = "CFBundleShortVersionString"
}
