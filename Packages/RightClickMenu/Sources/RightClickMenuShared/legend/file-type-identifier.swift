/// The name a file type is known by, everywhere, forever.
///
/// An id is a namespace and a name either side of a colon, such as `core:plain-text`.
/// The namespace says who the type came from, so a type the user made can never
/// collide with one shipped in the app.
///
/// Not a display name. Nothing here is ever shown to anybody.

/// Why a piece of text could not be read as an id.
public enum FileTypeIdentifierError: Error, Equatable, Sendable {

    /// The text held no separator, or held more than one.
    case missingSeparator

    /// There was nothing before the separator.
    case emptyNamespace

    /// There was nothing after the separator.
    case emptyName

    /// A character appeared that ids do not allow.
    case invalidCharacter
}

/// A namespaced name for one file type, checked when it is made.
///
/// Holding one is proof it is well formed: there is no way to make an invalid one,
/// so nothing downstream has to check it again.
public struct FileTypeIdentifier: Hashable, Sendable {

    /// Who the type came from, such as `core` or `user.will`.
    public let namespace: String

    /// What the type is called within its namespace, such as `plain-text`.
    public let name: String

    /// Builds an id from text such as `core:plain-text`.
    ///
    /// - Parameter text: Namespace and name either side of a single colon.
    /// - Throws: ``FileTypeIdentifierError`` saying which rule the text broke.
    public init(_ text: String) throws {
        let parts = text.split(
            separator: IdentifierConstants.separator,
            omittingEmptySubsequences: false
        )
        guard parts.count == IdentifierConstants.partCount else {
            throw FileTypeIdentifierError.missingSeparator
        }

        let namespace = String(parts[0])
        let name = String(parts[1])
        guard !namespace.isEmpty else { throw FileTypeIdentifierError.emptyNamespace }
        guard !name.isEmpty else { throw FileTypeIdentifierError.emptyName }

        let namespaceIsClean = Self.holdsOnlyAllowed(
            namespace,
            extra: IdentifierConstants.namespaceExtraCharacters
        )
        let nameIsClean = Self.holdsOnlyAllowed(
            name,
            extra: IdentifierConstants.nameExtraCharacters
        )
        guard namespaceIsClean, nameIsClean else {
            throw FileTypeIdentifierError.invalidCharacter
        }

        self.namespace = namespace
        self.name = name
    }

    /// The id written back out, the same way it was written in.
    public var text: String {
        "\(namespace)\(IdentifierConstants.separator)\(name)"
    }

    private static func holdsOnlyAllowed(_ part: String, extra: String) -> Bool {
        part.allSatisfy { character in
            character.isASCII
                && (character.isLetter || character.isNumber || extra.contains(character))
        }
    }
}

// MARK: - Reading and writing

extension FileTypeIdentifier: Codable {

    /// Reads an id from a plain string, refusing a malformed one rather than carrying it.
    ///
    /// - Parameter decoder: The decoder holding the string.
    /// - Throws: A decoding error if the value is not a string, or the reason it is not an id.
    public init(from decoder: any Decoder) throws {
        try self.init(try decoder.singleValueContainer().decode(String.self))
    }

    /// Writes the id as a plain string, so a legend file stays readable by a person.
    ///
    /// - Parameter encoder: The encoder to write into.
    /// - Throws: Whatever the encoder throws.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(text)
    }
}

// MARK: - Sorting

extension FileTypeIdentifier: Comparable {

    /// Orders ids by namespace, then by name, so a written legend has a stable order.
    ///
    /// - Parameters:
    ///   - lhs: The id on the left.
    ///   - rhs: The id on the right.
    /// - Returns: `true` when `lhs` sorts before `rhs`.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.namespace, lhs.name) < (rhs.namespace, rhs.name)
    }
}
