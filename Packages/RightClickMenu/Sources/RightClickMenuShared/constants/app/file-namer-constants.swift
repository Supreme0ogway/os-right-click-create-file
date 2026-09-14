/// Fixed facts about choosing a name for a new file.
public enum FileNamerConstants {

    /// The number the count starts at when the plain name is already taken.
    public static let firstSuffix = 2

    /// How many names to try before giving up. Far past anything a person would make.
    public static let maximumAttempts = 1000

    /// What goes between the name and the count, as in `Untitled 2`.
    public static let suffixSeparator = " "

    /// Characters that would send the file somewhere other than the chosen folder.
    public static let forbiddenCharacters = "/:"
}
