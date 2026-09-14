import Foundation

/// Working out what the right click menu should offer.
///
/// The Finder extension asks this and builds exactly what it is told, so the decision
/// about what appears lives here where it can be tested without a Finder.
///
/// The important answer is the empty one. A legend with nothing in it plans nothing,
/// and the extension shows no menu at all rather than an empty group, so somebody who
/// removed every type gets a right click menu that looks untouched.

/// One thing the menu offers.
public struct MenuEntry: Hashable, Sendable {

    /// What the entry says, already looked up in the user's language.
    public let title: String

    /// The type this entry makes.
    public let typeId: FileTypeIdentifier

    /// Where this entry sits in the menu, counting from zero.
    ///
    /// The number is how a click finds its way back to a type. A menu handed to the
    /// Finder is packed up and sent to another process, and only the plain parts of
    /// an entry survive that trip, so the type has to travel as a number.
    public let place: Int
}

/// Turns a legend into the entries the menu should hold.
public enum MenuPlan {

    /// The entries for this legend, in the order they should appear.
    ///
    /// - Parameter legend: The file types the user has.
    /// - Returns: One entry per type. Empty when the legend is empty.
    public static func entries(for legend: Legend) -> [MenuEntry] {
        legend.types.enumerated().map { place, type in
            MenuEntry(title: title(for: type), typeId: type.id, place: place)
        }
    }

    /// Finds the entry a click came from.
    ///
    /// - Parameters:
    ///   - place: The number the clicked entry carried.
    ///   - legend: The file types as they stand now.
    /// - Returns: The entry, or `nil` when the list changed since the menu was built.
    public static func entry(at place: Int, in legend: Legend) -> MenuEntry? {
        let all = entries(for: legend)
        guard all.indices.contains(place) else { return nil }
        return all[place]
    }

    /// What the one entry in the right click menu is called.
    ///
    /// The file types hang off it rather than sitting in the menu themselves, so the
    /// Finder's own menu gains one line however many types somebody has.
    public static var parentTitle: String {
        String(
            localized: "menu.parent",
            bundle: .module,
            comment: "The one entry added to the right click menu"
        )
    }

    /// Whether a menu should be shown at all.
    ///
    /// When this is `false` the extension must show nothing, not an empty menu, so the
    /// Finder draws no heading and no separator of its own.
    ///
    /// - Parameter legend: The file types the user has.
    /// - Returns: `true` when there is at least one entry to show.
    public static func hasAnythingToShow(_ legend: Legend) -> Bool {
        !legend.isEmpty
    }

    private static func title(for type: FileType) -> String {
        String(format: newFileFormat, type.displayName)
    }

    private static let newFileFormat = String(
        localized: "menu.new-file",
        bundle: .module,
        comment: "Right click menu entry that makes one new file"
    )
}
