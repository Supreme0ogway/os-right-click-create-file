/// The shapes an id is allowed to take.
///
/// Read by the app and by the Finder extension, so both agree on what counts as a
/// well formed id. Deliberately not a place for anything that has to be worked out.
public enum IdentifierConstants {

    /// The one character between a namespace and a name.
    public static let separator: Character = ":"

    /// How many parts an id splits into. A second separator means the text is not an id.
    public static let partCount = 2

    /// Characters a namespace may hold, beyond letters and digits.
    public static let namespaceExtraCharacters = "-."

    /// Characters a name may hold, beyond letters and digits.
    public static let nameExtraCharacters = "-"

    /// The namespace every type shipped with the app belongs to.
    public static let builtInNamespace = "core"

    /// The namespace prefix a type the user made belongs to.
    public static let userNamespacePrefix = "user"
}
