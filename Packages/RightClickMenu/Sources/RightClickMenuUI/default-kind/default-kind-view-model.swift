import Observation

/// What the setting for the add screen's starting kind knows and can do.
///
/// Follows the store and writes every change back through it, so the add screen reads
/// the same answer this setting shows.
@MainActor
@Observable
public final class DefaultKindViewModel {

    /// The kinds of file the app knows, to pick a starting one from.
    public let choices: [FileType]

    /// The store this setting reads and writes.
    public let store: RecordStore<Preferences>

    /// The kind the add screen starts on.
    public private(set) var picked: DefaultKind = .custom("")

    @ObservationIgnored private var subscription: StoreSubscription?

    /// Builds the setting's model and starts following the store.
    ///
    /// - Parameters:
    ///   - known: The kinds of file the app knows about.
    ///   - store: The one copy of the choices the app remembers.
    public init(known: Legend, store: RecordStore<Preferences>) {
        choices = known.types
        self.store = store
        subscription = store.subscribe { [weak self] preferences in
            self?.picked = preferences.defaultKind
        }
    }

    /// Whether the add screen starts ready for a typed extension.
    public var isCustom: Bool {
        guard case .custom = picked else { return false }
        return true
    }

    /// The extension of the known kind being started on, empty while on custom.
    public var pickedExtension: String {
        guard case .known(let fileExtension) = picked else { return "" }
        return fileExtension
    }

    /// The extension the add screen starts with while on custom.
    ///
    /// Empty means nothing is filled in and it has to be typed every time.
    public var customExtension: String {
        guard case .custom(let remembered) = picked else { return "" }
        return remembered
    }

    /// Remembers which kind the add screen should start on.
    ///
    /// - Parameter kind: The kind to start on.
    public func choose(_ kind: DefaultKind) {
        try? store.save(store.value.startingWith(kind))
    }

    /// Starts on one of the kinds the app knows.
    ///
    /// - Parameter fileExtension: The extension of the kind to start on.
    public func pick(_ fileExtension: String) {
        choose(.known(fileExtension))
    }

    /// Starts ready for an extension to be typed, keeping any already remembered.
    public func useCustom() {
        guard !isCustom else { return }
        choose(.custom(""))
    }

    /// Remembers the extension the add screen starts with while on custom.
    ///
    /// - Parameter text: The extension, or blank to fill it in every time.
    public func setCustomExtension(_ text: String) {
        choose(.custom(FileTypeCheck.tidied(text)))
    }
}
