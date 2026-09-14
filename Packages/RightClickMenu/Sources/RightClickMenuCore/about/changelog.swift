import Foundation

/// What changed, and when.
///
/// Kept as a data file next to the code rather than written into a screen, so a
/// release can be described without touching Swift. The about screen shows only the
/// newest one: a person looking at it wants to know what just changed, not the history.

/// One release and what it changed.
public struct Release: Codable, Equatable, Sendable, Identifiable {

    /// The version this release was, such as `0.1`.
    public let version: String

    /// The day it was made, as year, month and day.
    public let when: String

    /// What changed, one line each.
    public let notes: [String]

    /// The version, which is what tells two releases apart.
    public var id: String { version }
}

/// Every release, newest first.
public struct Changelog: Codable, Equatable, Sendable {

    /// The shape this file was written in.
    public let version: Int

    /// The releases, newest first.
    public let releases: [Release]

    /// The newest release, or `nil` when there are none.
    public var latest: Release? { releases.first }

    /// Reads the changelog shipped inside the app.
    ///
    /// - Returns: The releases, or an empty changelog when the file is missing.
    public static func load() -> Self {
        guard let fileURL = Bundle.module.url(
            forResource: AboutConstants.changelogResource,
            withExtension: DefaultsConstants.builtInLegendExtension
        ) else { return Self.none }

        return RecordFile.read(from: fileURL, fallback: Self.none)
    }

    private static let none = Self(version: LegendConstants.schemaVersion, releases: [])
}
