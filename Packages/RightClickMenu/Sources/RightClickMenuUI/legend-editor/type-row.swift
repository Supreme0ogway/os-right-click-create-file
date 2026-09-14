import SwiftUI

/// One file type in the list, with the extension it writes.
///
/// The colors are worked out here and written down as fixed ones, rather than left as
/// the system's own light-or-dark colors. A row lifted out by a drag is drawn again
/// somewhere that does not inherit the window's light or dark, and anything that is
/// still asking the system at that point comes back with the wrong answer, which is
/// how a dragged row came out as black words on a dark list.
struct TypeRow: View {

    let type: FileType
    let appearance: ColorScheme

    var body: some View {
        HStack {
            Text(type.displayName)
                .foregroundStyle(words)
            Spacer()
            Text(type.fileExtension)
                .font(.caption.monospaced())
                .foregroundStyle(words.opacity(TypeRowLook.extensionFade))
        }
    }

    private var words: Color {
        appearance == .dark ? .white : .black
    }
}

/// How far back the quieter parts of a row sit.
enum TypeRowLook {

    /// How much of the row's color the extension keeps.
    static let extensionFade: CGFloat = 0.55
}
