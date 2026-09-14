/// The choices the app remembers between launches.
///
/// Small things somebody set once and should not have to set again. Kept apart from
/// the file types and from where the menu appears, because losing one of those would
/// matter and losing this would not.

/// Which kind the add screen starts on.
///
/// Written out by hand rather than left to the compiler, because the compiler spells a
/// choice like this with a field called `_0`, and these files are meant to be opened
/// and read by a person.
public enum DefaultKind: Hashable, Sendable {

    /// One of the kinds the app already knows, named by its extension.
    case known(String)

    /// Ready for an extension to be typed in, starting from this one.
    ///
    /// Empty means nothing is filled in and the extension has to be typed every time.
    case custom(String)
}

extension DefaultKind: Codable {

    private enum Key: String, CodingKey {
        case kind
        case fileExtension
    }

    /// Reads a starting kind, treating anything unexpected as custom.
    ///
    /// - Parameter decoder: The decoder holding the choice.
    /// - Throws: A decoding error when the value is not an object at all.
    public init(from decoder: any Decoder) throws {
        let holder = try decoder.container(keyedBy: Key.self)
        let named = try holder.decode(String.self, forKey: .kind)

        let fileExtension = try holder.decodeIfPresent(String.self, forKey: .fileExtension)

        guard named == PreferencesConstants.knownKindName, let fileExtension else {
            self = .custom(fileExtension ?? "")
            return
        }
        self = .known(fileExtension)
    }

    /// Writes the starting kind as a small object a person can read.
    ///
    /// - Parameter encoder: The encoder to write into.
    /// - Throws: Whatever the encoder throws.
    public func encode(to encoder: any Encoder) throws {
        var holder = encoder.container(keyedBy: Key.self)

        guard case .known(let fileExtension) = self else {
            try holder.encode(PreferencesConstants.customKindName, forKey: .kind)
            guard case .custom(let remembered) = self, !remembered.isEmpty else { return }
            try holder.encode(remembered, forKey: .fileExtension)
            return
        }
        try holder.encode(PreferencesConstants.knownKindName, forKey: .kind)
        try holder.encode(fileExtension, forKey: .fileExtension)
    }
}

/// What the app remembers.
public struct Preferences: Hashable, Codable, Sendable {

    /// The shape this was written in.
    public let version: Int

    /// The kind the add screen starts on.
    ///
    /// Somebody who mostly adds one kind sets this once rather than picking it every
    /// time. A kind that is no longer in the list is ignored and the screen starts on
    /// the first one, so removing a type can never leave the add screen stuck.
    public let defaultKind: DefaultKind

    /// What an app with nothing set up uses.
    public static let fallback = Self(defaultKind: .known(DefaultsConstants.fallbackExtension))

    /// Builds the choices.
    ///
    /// - Parameters:
    ///   - version: The shape they are written in. Defaults to today's.
    ///   - defaultKind: The kind the add screen starts on.
    public init(
        version: Int = PreferencesConstants.schemaVersion,
        defaultKind: DefaultKind
    ) {
        self.version = version
        self.defaultKind = defaultKind
    }

    /// The same choices with a different starting kind.
    ///
    /// - Parameter kind: The kind the add screen should start on.
    /// - Returns: A new set of choices. The original is untouched.
    public func startingWith(_ kind: DefaultKind) -> Self {
        Self(version: version, defaultKind: kind)
    }
}
