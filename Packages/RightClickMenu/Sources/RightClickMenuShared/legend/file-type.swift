/// One kind of file the user can make from the right click menu.
///
/// A record, not a behaviour: it says what the file is called and what goes inside it,
/// and nothing about how it gets written or how it is shown.

/// A file type the menu can offer.
public struct FileType: Hashable, Codable, Sendable, Identifiable {

    /// The name this type is known by. Never shown to anybody.
    public let id: FileTypeIdentifier

    /// What the user sees, such as `Text File`.
    public let displayName: String

    /// The extension the written file gets, with no dot, such as `txt`.
    public let fileExtension: String

    /// What a new file is called before the extension, such as `Untitled`.
    public let defaultBaseName: String

    /// What goes inside a new file. Empty makes an empty file, which is normal.
    public let template: String

    /// Builds a file type.
    ///
    /// - Parameters:
    ///   - id: The namespaced name for this type.
    ///   - displayName: What the user sees in the menu and the editor.
    ///   - fileExtension: The extension with no dot. A leading dot is dropped.
    ///   - defaultBaseName: The name before the extension. Blank falls back to `Untitled`.
    ///   - template: The text a new file starts with. Empty is normal.
    public init(
        id: FileTypeIdentifier,
        displayName: String,
        fileExtension: String,
        defaultBaseName: String,
        template: String
    ) {
        let trimmedBaseName = defaultBaseName.trimmed

        self.id = id
        self.displayName = displayName
        self.fileExtension = Self.withoutLeadingDot(fileExtension)
        self.defaultBaseName = trimmedBaseName.isEmpty
            ? LegendConstants.fallbackBaseName
            : trimmedBaseName
        self.template = template
    }

    private static func withoutLeadingDot(_ fileExtension: String) -> String {
        let trimmed = fileExtension.trimmed
        guard trimmed.hasPrefix(ExtensionConstants.dot) else { return trimmed }
        return String(trimmed.dropFirst())
    }
}
