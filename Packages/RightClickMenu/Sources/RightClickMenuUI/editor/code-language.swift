/// Which language an extension is written in.
///
/// Only used to decide how to color the box somebody types a template into. An
/// extension nobody recognises is not a fault: the text is simply left plain.
///
/// The names on the right are the ones the coloring library knows, which are not
/// always the ones a person would say, so the mapping is written down and checked.
enum CodeLanguage {

    /// The language behind an extension.
    ///
    /// - Parameter fileExtension: The extension, with or without capitals or space.
    /// - Returns: The language name, or `nil` when there is nothing to color.
    static func forExtension(_ fileExtension: String) -> String? {
        byExtension[fileExtension.trimmed.lowercased()]
    }

    private static let byExtension: [String: String] = [
        "bash": "bash",
        "c": "c",
        "cpp": "cpp",
        "cs": "csharp",
        "css": "css",
        "go": "go",
        "h": "c",
        "htm": "xml",
        "html": "xml",
        "ini": "ini",
        "java": "java",
        "js": "javascript",
        "json": "json",
        "jsx": "javascript",
        "kt": "kotlin",
        "lua": "lua",
        "m": "objectivec",
        "md": "markdown",
        "php": "php",
        "pl": "perl",
        "py": "python",
        "r": "r",
        "rb": "ruby",
        "rs": "rust",
        "scss": "scss",
        "sh": "bash",
        "sql": "sql",
        "svg": "xml",
        "swift": "swift",
        "toml": "ini",
        "ts": "typescript",
        "tsx": "typescript",
        "vue": "xml",
        "xml": "xml",
        "yaml": "yaml",
        "yml": "yaml",
        "zsh": "bash",
    ]
}
