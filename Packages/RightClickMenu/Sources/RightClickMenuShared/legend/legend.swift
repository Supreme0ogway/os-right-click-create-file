/// The whole set of file types the right click menu offers.
///
/// One reading of it is the truth for the menu, the editor and the writer alike.
/// An empty legend is a normal legend: it means the menu shows nothing at all.

/// Every file type the user has, in the order they are shown.
public struct Legend: Hashable, Codable, Sendable {

    /// The shape this legend was written in.
    public let version: Int

    /// The types, in menu order, each id appearing once.
    public let types: [FileType]

    /// A legend holding no types. What an app with nothing set up answers with.
    public static let empty = Self(types: [])

    /// Builds a legend, dropping any repeated id and keeping the first of each.
    ///
    /// - Parameters:
    ///   - version: The shape the legend is written in. Defaults to today's.
    ///   - types: The types in the order they should appear in the menu.
    public init(version: Int = LegendConstants.schemaVersion, types: [FileType]) {
        self.version = version
        self.types = Self.withoutRepeats(types)
    }

    /// Whether the legend offers nothing, in which case the menu shows nothing.
    public var isEmpty: Bool { types.isEmpty }

    /// Finds the type with this id.
    ///
    /// - Parameter id: The id to look for.
    /// - Returns: The type, or `nil` when the legend does not hold it.
    public func type(withId id: FileTypeIdentifier) -> FileType? {
        types.first { $0.id == id }
    }

    /// A legend with this type in it, replacing any type that already had its id.
    ///
    /// A new id goes on the end. A known id keeps its place in the order.
    ///
    /// - Parameter type: The type to put in.
    /// - Returns: A new legend. The original is untouched.
    public func adding(_ type: FileType) -> Self {
        guard self.type(withId: type.id) != nil else {
            return Self(version: version, types: types + [type])
        }
        return Self(version: version, types: types.map { $0.id == type.id ? type : $0 })
    }

    /// A legend without the type with this id.
    ///
    /// Removing the last type is allowed and leaves an empty legend, which is a
    /// state the whole app is built to handle.
    ///
    /// - Parameter id: The id to take out. An id that is not there changes nothing.
    /// - Returns: A new legend. The original is untouched.
    public func removing(_ id: FileTypeIdentifier) -> Self {
        Self(version: version, types: types.filter { $0.id != id })
    }

    /// A legend with some types moved to a new place in the order.
    ///
    /// The order is what the right click menu shows, so moving a type here is how
    /// somebody decides where it appears in that menu.
    ///
    /// - Parameters:
    ///   - offsets: Where the types being moved are now.
    ///   - destination: Where they should land, counted before anything is taken out,
    ///     which is how a list hands over a drag.
    /// - Returns: A new legend. The original is untouched.
    public func moving(from offsets: [Int], to destination: Int) -> Self {
        let taken = offsets.sorted().filter { types.indices.contains($0) }
        guard !taken.isEmpty else { return self }

        let moving = taken.map { types[$0] }
        let staying = types.enumerated()
            .filter { !taken.contains($0.offset) }
            .map(\.element)

        let landing = destination - taken.filter { $0 < destination }.count
        return Self(version: version, types: inserting(moving, into: staying, at: landing))
    }

    private func inserting(
        _ moving: [FileType],
        into staying: [FileType],
        at landing: Int
    ) -> [FileType] {
        let place = min(max(landing, 0), staying.count)
        return Array(staying[..<place]) + moving + Array(staying[place...])
    }

    private static func withoutRepeats(_ types: [FileType]) -> [FileType] {
        var seen = Set<FileTypeIdentifier>()
        return types.filter { seen.insert($0.id).inserted }
    }
}
