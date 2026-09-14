/// The words the Finder extension and the app use to ask for a new file.
public enum RequestConstants {

    /// The only thing the extension ever asks the app to do.
    public static let createAction = "create"

    /// The part of the address naming which type of file to make.
    public static let typeField = "type"

    /// The part of the address naming the folder to make it in.
    public static let folderField = "folder"
}

/// Fixed facts about the note the extension leaves after each click.
public enum TrailConstants {

    /// The file the extension writes what it last did into.
    public static let fileName = "last-request.json"
}
