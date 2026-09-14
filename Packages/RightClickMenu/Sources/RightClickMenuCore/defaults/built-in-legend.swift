import Foundation

/// The file types the app arrives with.
///
/// Kept as a data file next to this one, not as code, so a type can be added or its
/// wording changed without touching Swift. The user's own legend replaces it entirely
/// the first time they save one.

/// Reads the lists of types shipped inside the app.
public enum BuiltInLegend {

    /// The types the app arrives with.
    ///
    /// Answers with an empty legend if the shipped file is missing or damaged, which
    /// would be a build mistake rather than anything a user did.
    ///
    /// - Returns: The shipped legend, or an empty one.
    public static func load() -> Legend {
        read(DefaultsConstants.builtInLegendResource)
    }

    /// Every type the add screen offers to pick from.
    ///
    /// A longer list than the app arrives with, so somebody adding a type usually
    /// picks one rather than typing an extension by hand.
    ///
    /// - Returns: The shipped list, or an empty one when it is missing or damaged.
    public static func knownTypes() -> Legend {
        read(DefaultsConstants.knownTypesResource)
    }

    private static func read(_ resource: String) -> Legend {
        guard let fileURL = Bundle.module.url(
            forResource: resource,
            withExtension: DefaultsConstants.builtInLegendExtension
        ) else { return .empty }

        return RecordFile.read(from: fileURL, fallback: .empty)
    }
}
