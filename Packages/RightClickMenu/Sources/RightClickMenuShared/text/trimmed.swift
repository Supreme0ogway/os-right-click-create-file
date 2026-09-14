/// Taking the blank space off the ends of a piece of text.
///
/// Written against the standard library on purpose. This layer is the floor every
/// other layer stands on and imports nothing, so it behaves the same in the app and
/// inside the Finder extension.

extension StringProtocol {

    /// The text with any blank space taken off both ends.
    ///
    /// Space inside the text is kept, because that is part of what somebody typed.
    /// Text that is nothing but blank space comes back empty.
    public var trimmed: String {
        let withoutFront = drop(while: \.isWhitespace)
        let withoutBack = withoutFront.reversed().drop(while: \.isWhitespace).reversed()
        return String(withoutBack)
    }
}
