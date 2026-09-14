import AppKit
import UniformTypeIdentifiers

/// Asking the user for a file, or for somewhere to put one.
///
/// Uses the system's own panels, so where the user may reach and what picking a file
/// allows are the operating system's business rather than this app's.
enum FilePanel {

    /// Asks where a file should be written.
    ///
    /// - Parameter name: What the file should be called by default.
    /// - Returns: Where to write it, or `nil` when the user backed out.
    static func askWhereToSave(named name: String) -> URL? {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = name
        panel.allowedContentTypes = [.json]
        panel.message = UIText.chooseDestination

        guard panel.runModal() == .OK else { return nil }
        return panel.url
    }

    /// Asks which file to read.
    ///
    /// - Returns: The file, or `nil` when the user backed out.
    static func askForJSONFile() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]
        panel.message = UIText.chooseSource

        guard panel.runModal() == .OK else { return nil }
        return panel.url
    }
}
