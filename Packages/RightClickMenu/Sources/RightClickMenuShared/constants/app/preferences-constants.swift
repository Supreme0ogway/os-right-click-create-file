/// Fixed facts about the choices the app remembers between launches.
public enum PreferencesConstants {

    /// The shape preferences are written in today.
    public static let schemaVersion = 1

    /// The name of the file the choices are kept in, inside the shared container.
    public static let fileName = "preferences.json"

    /// What a starting kind taken from the app's own list is called in the file.
    public static let knownKindName = "known"

    /// What a starting kind whose extension is typed in is called in the file.
    public static let customKindName = "custom"
}
