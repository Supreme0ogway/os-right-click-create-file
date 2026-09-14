import Observation

/// What the legend editor screen knows and can do.
///
/// Holds no copy of the file types. It follows the store, and every change it makes
/// goes back through the store, so the right click menu and this screen can never
/// disagree about what the list says.
///
/// Imports nothing to do with drawing, which is what lets the rules below be tested
/// without a screen.
@MainActor
@Observable
public final class LegendEditorViewModel {

    /// The store this screen reads and writes. The only copy of the list.
    public let store: RecordStore<Legend>

    /// The file types, in the order they appear in the right click menu.
    public private(set) var types: [FileType] = []

    /// What has been typed into the search box.
    public var search = ""

    /// The last thing that went wrong, if anything did.
    public private(set) var problem: String?

    @ObservationIgnored private var subscription: StoreSubscription?
    @ObservationIgnored private var nextNewNumber = 1

    /// Builds the screen's model and starts following the store.
    ///
    /// - Parameter store: The one copy of the file types.
    public init(store: RecordStore<Legend>) {
        self.store = store
        subscription = store.subscribe { [weak self] legend in
            self?.types = legend.types
        }
    }

    /// The types to show, once the search box has been taken into account.
    ///
    /// A blank search shows everything. Otherwise a type is shown when the search
    /// appears in its name or its extension, so both "mark" and "md" find markdown.
    public var shownTypes: [FileType] {
        let wanted = search.trimmed.lowercased()
        guard !wanted.isEmpty else { return types }
        return types.filter { matches($0, wanted) }
    }

    /// Whether to tell the user the list is empty.
    ///
    /// An empty list is allowed. It means the right click menu shows nothing at all,
    /// which the message explains so it does not look like a fault.
    public var showsEmptyMessage: Bool { types.isEmpty }

    /// Whether the search found nothing, as opposed to there being nothing at all.
    public var showsNoMatchesMessage: Bool { !types.isEmpty && shownTypes.isEmpty }

    /// Adds a new file type to the end of the list.
    ///
    /// The new type belongs to the user, so it can never clash with one shipped in
    /// the app, and it is filled in enough to be usable straight away.
    ///
    /// - Returns: The new type's id so it can be shown at once, or `nil` when the
    ///   list is already as long as it is allowed to get.
    @discardableResult
    public func addType() -> FileTypeIdentifier? {
        guard let type = makeNewType() else { return nil }
        write(store.value.adding(type))
        return type.id
    }

    /// Removes a file type.
    ///
    /// Removing the last one is allowed, and leaves the right click menu showing
    /// nothing at all.
    ///
    /// - Parameter id: The type to take out.
    public func removeType(_ id: FileTypeIdentifier) {
        write(store.value.removing(id))
    }

    /// Saves a change to a type, keeping its place in the list.
    ///
    /// - Parameter type: The type as it now stands.
    public func updateType(_ type: FileType) {
        write(store.value.adding(type))
    }

    /// Puts a type built on the add screen into the list.
    ///
    /// - Parameter type: The type that was built.
    public func add(_ type: FileType) {
        write(store.value.adding(type))
    }

    /// Replaces the whole list, for when one is brought in from a file.
    ///
    /// - Parameter legend: The list as it should now stand.
    public func replaceAll(with legend: Legend) {
        write(legend)
    }

    /// Whether a type is filled in enough to appear in the menu.
    ///
    /// - Parameter type: The type to look at.
    /// - Returns: `true` when it has a name to show.
    public func isReady(_ type: FileType) -> Bool {
        !type.displayName.trimmed.isEmpty
    }

    private func matches(_ type: FileType, _ wanted: String) -> Bool {
        type.displayName.lowercased().contains(wanted)
            || type.fileExtension.lowercased().contains(wanted)
    }

    private func write(_ legend: Legend) {
        do {
            try store.save(legend)
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }

    private func makeNewType() -> FileType? {
        let taken = Set(types.map(\.id.text))
        for _ in 0..<LegendConstants.maximumTypeCount {
            let candidate = "\(IdentifierConstants.userNamespacePrefix).new:type-\(nextNewNumber)"
            nextNewNumber += 1
            guard taken.contains(candidate) else { return newType(withId: candidate) }
        }
        return nil
    }

    private func newType(withId text: String) -> FileType? {
        guard let id = try? FileTypeIdentifier(text) else { return nil }
        return FileType(
            id: id,
            displayName: UIText.newTypeName,
            fileExtension: UIText.newTypeExtension,
            defaultBaseName: LegendConstants.fallbackBaseName,
            template: ""
        )
    }
}
