/// Where the right click menu is allowed to appear.
///
/// Either everywhere, or a list of folders the user picked by hand. A picked folder
/// covers everything inside it too, so nobody has to add a folder's children.
///
/// Folders are kept as plain text, not as a file URL, because this layer is the floor
/// every other layer stands on and imports nothing.

/// The places the menu appears, and the shape that setting is stored in.
public struct Scope: Hashable, Codable, Sendable {

    /// The two answers to "where should the menu appear".
    ///
    /// Written out by hand rather than left to the compiler, because the compiler
    /// spells a choice like this with a field called `_0`, and these files are meant
    /// to be opened and read by a person.
    public enum Places: Hashable, Sendable {

        /// Anywhere the Finder will let the extension look.
        case everywhere

        /// Only these folders and everything inside them.
        case folders([String])
    }

    /// The shape this setting was written in.
    public let version: Int

    /// Where the menu appears.
    public let places: Places

    /// Watching everything. What an app with nothing set up uses.
    public static let everywhere = Self(places: .everywhere)

    /// What to fall back to when no setting has been saved yet.
    public static let fallback = everywhere

    /// Builds a scope, tidying folder paths so one folder is never watched twice.
    ///
    /// Blank text is dropped, a trailing slash is taken off, and a repeated folder is
    /// dropped keeping the first of each. The root stays as it is, being only a slash.
    ///
    /// - Parameters:
    ///   - version: The shape the setting is written in. Defaults to today's.
    ///   - places: Everywhere, or the folders the user picked.
    public init(version: Int = ScopeConstants.schemaVersion, places: Places) {
        self.version = version
        self.places = Self.tidied(places)
    }

    /// The folders being watched, empty when the scope is everywhere.
    public var folderPaths: [String] {
        guard case .folders(let paths) = places else { return [] }
        return paths
    }

    /// Whether the menu appears nowhere at all.
    ///
    /// True only when the user picked folders and then removed every one of them,
    /// which is allowed and means the menu is switched off without being uninstalled.
    public var watchesNothing: Bool {
        guard case .folders(let paths) = places else { return false }
        return paths.isEmpty
    }

    /// A scope with this folder added to the end.
    ///
    /// Adding a folder to an everywhere scope narrows it to just that folder, because
    /// picking a folder is how somebody says they no longer want everywhere.
    ///
    /// - Parameter path: The folder to watch.
    /// - Returns: A new scope. The original is untouched.
    public func addingFolder(_ path: String) -> Self {
        Self(version: version, places: .folders(folderPaths + [path]))
    }

    /// A scope without this folder.
    ///
    /// - Parameter path: The folder to stop watching. One that is not there changes nothing.
    /// - Returns: A new scope. The original is untouched.
    public func removingFolder(_ path: String) -> Self {
        let wanted = Self.tidiedPath(path)
        return Self(version: version, places: .folders(folderPaths.filter { $0 != wanted }))
    }

    private static func tidied(_ places: Places) -> Places {
        guard case .folders(let paths) = places else { return places }
        var seen = Set<String>()
        let clean = paths
            .map(tidiedPath)
            .filter { !$0.isEmpty && seen.insert($0).inserted }
        return .folders(clean)
    }

    private static func tidiedPath(_ path: String) -> String {
        let trimmed = path.trimmed
        let isLongerThanRoot = trimmed.count > ScopeConstants.rootPath.count
        guard isLongerThanRoot, trimmed.hasSuffix(ScopeConstants.rootPath) else { return trimmed }
        return String(trimmed.dropLast())
    }
}

// MARK: - Reading and writing

extension Scope.Places: Codable {

    private enum Key: String, CodingKey {
        case placesKind = "where"
        case folders
    }

    /// Reads where the menu appears, treating anything unexpected as everywhere.
    ///
    /// Everywhere is the safer of the two to fall back to: the worst it does is offer
    /// the menu somewhere it was not wanted, where falling back to a list of no
    /// folders would switch the menu off without saying so.
    ///
    /// - Parameter decoder: The decoder holding the choice.
    /// - Throws: A decoding error when the value is not an object at all.
    public init(from decoder: any Decoder) throws {
        let holder = try decoder.container(keyedBy: Key.self)
        let named = try holder.decode(String.self, forKey: .placesKind)

        guard named == ScopeConstants.foldersName else {
            self = .everywhere
            return
        }
        self = .folders(try holder.decodeIfPresent([String].self, forKey: .folders) ?? [])
    }

    /// Writes where the menu appears as a small object a person can read.
    ///
    /// - Parameter encoder: The encoder to write into.
    /// - Throws: Whatever the encoder throws.
    public func encode(to encoder: any Encoder) throws {
        var holder = encoder.container(keyedBy: Key.self)

        guard case .folders(let paths) = self else {
            try holder.encode(ScopeConstants.everywhereName, forKey: .placesKind)
            return
        }
        try holder.encode(ScopeConstants.foldersName, forKey: .placesKind)
        try holder.encode(paths, forKey: .folders)
    }
}
