import Foundation

/// Turning a scope into the exact folders the Finder is told to watch.
///
/// The Finder only offers a menu inside folders the extension named, and a named
/// folder covers everything below it. So watching everywhere is watching the top of
/// the disk.
///
/// - Note: A plugged in drive is a separate mount and is not covered by watching the
///   top, so each drive has to be named as well. Losing that is how the menu quietly
///   stops appearing on an external disk.

/// Works out which folders the extension should watch.
public enum WatchList {

    /// The folders to watch for this scope.
    ///
    /// - Parameters:
    ///   - scope: Everywhere, or the folders the user picked.
    ///   - volumeRoots: The drives mounted right now. Only used for everywhere.
    /// - Returns: The folders to hand to the Finder. Empty means no menu anywhere.
    public static func folderURLs(for scope: Scope, volumeRoots: [URL]) -> Set<URL> {
        guard case .folders(let paths) = scope.places else {
            return Set([URL(filePath: ScopeConstants.rootPath)] + volumeRoots)
        }
        return Set(paths.map { URL(filePath: $0) })
    }

    /// The folders to watch for this scope, asking the system which drives are mounted.
    ///
    /// - Parameter scope: Everywhere, or the folders the user picked.
    /// - Returns: The folders to hand to the Finder.
    public static func folderURLs(for scope: Scope) -> Set<URL> {
        folderURLs(for: scope, volumeRoots: mountedVolumeRoots())
    }

    private static func mountedVolumeRoots() -> [URL] {
        FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]
        ) ?? []
    }
}
