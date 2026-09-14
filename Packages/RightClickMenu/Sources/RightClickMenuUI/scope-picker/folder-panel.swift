import AppKit

/// Asking the user to pick a folder.
///
/// Uses the system's own panel, so the places the user can reach and the permission
/// that comes with picking are the operating system's business rather than this app's.
enum FolderPanel {

    /// Shows the panel and waits for an answer.
    ///
    /// - Returns: The folder that was picked, or `nil` when the user backed out.
    static func ask() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.message = UIText.chooseFolder
        panel.prompt = UIText.choose

        guard panel.runModal() == .OK else { return nil }
        return panel.url
    }
}
