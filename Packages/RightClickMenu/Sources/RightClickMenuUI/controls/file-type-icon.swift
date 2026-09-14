import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// The icon the mac itself uses for a file with this extension.
///
/// Asking the system means a spreadsheet looks like a spreadsheet and a script looks
/// like a script, with no pictures of our own to keep up to date. An extension nobody
/// knows falls back to a plain document.
public struct FileTypeIcon: View {

    private let fileExtension: String

    /// Builds the icon.
    ///
    /// - Parameter fileExtension: The extension to show the icon for.
    public init(fileExtension: String) {
        self.fileExtension = fileExtension
    }

    public var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(for: contentType))
            .resizable()
            .interpolation(.high)
            .frame(width: IconLayout.size, height: IconLayout.size)
            .accessibilityHidden(true)
    }

    private var contentType: UTType {
        let clean = fileExtension.trimmed.lowercased()
        guard !clean.isEmpty, let found = UTType(filenameExtension: clean) else {
            return .data
        }
        return found
    }
}

/// Fixed sizes for the file's icon.
public enum IconLayout {

    /// How big the icon is shown.
    public static let size: CGFloat = 52

    /// The space between the icon and the line under it.
    public static let gap: CGFloat = 6
}
