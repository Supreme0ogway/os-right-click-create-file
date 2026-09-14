import Foundation
import Observation

/// What the screen for choosing where the menu appears knows and can do.
///
/// Follows the store and writes every change back through it, so the Finder extension
/// reads the same answer this screen shows.
///
/// Imports nothing to do with drawing, so the rules below are covered by the ordinary
/// test run.
@MainActor
@Observable
public final class ScopePickerViewModel {

    /// The store this screen reads and writes. The only copy of the setting.
    public let store: RecordStore<Scope>

    /// Where the menu currently appears.
    public private(set) var scope: Scope = .fallback

    /// The last thing that went wrong, if anything did.
    public private(set) var problem: String?

    @ObservationIgnored private var subscription: StoreSubscription?

    /// Builds the screen's model and starts following the store.
    ///
    /// - Parameter store: The one copy of the setting.
    public init(store: RecordStore<Scope>) {
        self.store = store
        subscription = store.subscribe { [weak self] scope in
            self?.scope = scope
        }
    }

    /// Whether the menu appears everywhere.
    public var isEverywhere: Bool { scope.places == .everywhere }

    /// The folders the user picked, empty when the menu appears everywhere.
    public var folderPaths: [String] { scope.folderPaths }

    /// Whether to warn that the menu now appears nowhere at all.
    ///
    /// True only when folders were chosen and then every one was removed. That is
    /// allowed, and the warning is there so it does not look like a fault.
    public var showsNowhereWarning: Bool { scope.watchesNothing }

    /// Makes the menu appear everywhere.
    public func useEverywhere() {
        write(.everywhere)
    }

    /// Makes the menu appear only in folders the user picks.
    public func usePickedFolders() {
        guard isEverywhere else { return }
        write(Scope(places: .folders([])))
    }

    /// Adds a folder the menu should appear in, along with everything inside it.
    ///
    /// - Parameter folder: The folder that was picked.
    public func addFolder(_ folder: URL) {
        write(scope.addingFolder(folder.path))
    }

    /// Stops the menu appearing in a folder.
    ///
    /// Removing the last one is allowed and leaves the menu appearing nowhere.
    ///
    /// - Parameter path: The folder to drop.
    public func removeFolder(_ path: String) {
        write(scope.removingFolder(path))
    }

    private func write(_ scope: Scope) {
        do {
            try store.save(scope)
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }
}
