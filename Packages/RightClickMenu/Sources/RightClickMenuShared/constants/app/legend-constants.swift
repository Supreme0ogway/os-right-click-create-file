/// Fixed facts about a legend, agreed by the app and the Finder extension.
public enum LegendConstants {

    /// The shape legends are written in today. Every written legend carries it.
    public static let schemaVersion = 1

    /// The name of the file the legend is kept in, inside the shared container.
    public static let fileName = "legend.json"

    /// The base name a new file falls back to when a type names none.
    public static let fallbackBaseName = "Untitled"

    /// How many types the editor will hold. High enough never to be met by hand.
    public static let maximumTypeCount = 200
}

/// Fixed facts about taking a list of file types in and out of the app.
public enum TransferConstants {

    /// What a written out list of file types is called by default.
    public static let suggestedFileName = "file-types.json"
}
