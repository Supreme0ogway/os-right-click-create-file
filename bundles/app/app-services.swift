import Foundation
import RightClickMenuCore

/// The one place the app's stores are made.
///
/// Everything below gets them handed to it, so nothing has to go looking and a test
/// can hand in its own. Made once, when the app starts, and never replaced.
///
/// When the shared folder cannot be reached the stores fall back to files inside the
/// app's own folder. The app then still runs and still writes files; only the Finder
/// extension stops seeing the legend, which the menu bar says out loud.
@MainActor
final class AppServices {

    /// The file types the user has.
    let legend: RecordStore<Legend>

    /// Where the menu is allowed to appear.
    let scope: RecordStore<Scope>

    /// Whether the app and the Finder extension can actually share files.
    let sharesWithExtension: Bool

    /// Builds the stores and puts the shipped file types in place on a first run.
    init() {
        let folder = Self.storageFolder()
        sharesWithExtension = SharedContainer.canBeWrittenTo()

        legend = RecordStore(
            fileURL: folder.appending(path: LegendConstants.fileName),
            fallback: BuiltInLegend.load()
        )
        scope = RecordStore(
            fileURL: folder.appending(path: ScopeConstants.fileName),
            fallback: .fallback
        )

        saveFirstRunDefaults()
    }

    private func saveFirstRunDefaults() {
        try? legend.save(legend.value)
        try? scope.save(scope.value)
    }

    private static func storageFolder() -> URL {
        guard let shared = SharedContainer.folderURL else { return fallbackFolder() }
        return shared
    }

    private static func fallbackFolder() -> URL {
        URL.applicationSupportDirectory.appending(path: BundleConstants.appIdentifier)
    }
}
