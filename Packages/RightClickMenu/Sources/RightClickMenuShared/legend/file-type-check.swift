/// Whether what somebody typed can be part of a file type.
///
/// The same rules are asked twice: once on the screen that adds a type, and once on
/// the screen that changes one. Keeping them here means the two screens cannot drift,
/// and means the rules are checked without a screen at all.
///
/// Space around what was typed is never a fault. It is taken off, because nobody means
/// to name a type with a space on the end.

/// What is wrong with something somebody typed.
public enum FileTypeProblem: Equatable, Sendable {

    /// Nothing was typed.
    case missing

    /// A dot was typed, which would make a second extension.
    case holdsDot

    /// A space was typed inside, which an extension cannot hold.
    case holdsSpace

    /// A character was typed that would put the file somewhere else.
    case holdsPathCharacter
}

/// Checks the parts of a file type.
public enum FileTypeCheck {

    /// What somebody typed, with the space taken off both ends.
    ///
    /// - Parameter text: What was typed.
    /// - Returns: The same text with nothing blank around it.
    public static func tidied(_ text: String) -> String {
        text.trimmed
    }

    /// What is wrong with an extension, if anything.
    ///
    /// - Parameter text: What was typed.
    /// - Returns: The problem, or `nil` when it can be used.
    public static func extensionProblem(_ text: String) -> FileTypeProblem? {
        let clean = tidied(text)
        guard !clean.isEmpty else { return .missing }
        guard !clean.contains(ExtensionConstants.dot) else { return .holdsDot }
        guard !holdsPathCharacter(clean) else { return .holdsPathCharacter }
        guard !clean.contains(where: \.isWhitespace) else { return .holdsSpace }
        return nil
    }

    /// What is wrong with the name shown in the menu, if anything.
    ///
    /// - Parameter text: What was typed.
    /// - Returns: The problem, or `nil` when it can be used.
    public static func nameProblem(_ text: String) -> FileTypeProblem? {
        tidied(text).isEmpty ? .missing : nil
    }

    /// What is wrong with what new files are called, if anything.
    ///
    /// - Parameter text: What was typed.
    /// - Returns: The problem, or `nil` when it can be used.
    public static func baseNameProblem(_ text: String) -> FileTypeProblem? {
        let clean = tidied(text)
        guard !clean.isEmpty else { return .missing }
        guard !holdsPathCharacter(clean) else { return .holdsPathCharacter }
        return nil
    }

    private static func holdsPathCharacter(_ text: String) -> Bool {
        text.contains { FileNamerConstants.forbiddenCharacters.contains($0) }
    }
}
