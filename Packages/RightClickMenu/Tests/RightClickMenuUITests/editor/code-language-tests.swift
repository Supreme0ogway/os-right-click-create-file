import Testing

@testable import RightClickMenuUI

@Suite("Code language")
struct CodeLanguageTests {

    @Test("Knows the language behind a common extension", arguments: [
        ("js", "javascript"),
        ("py", "python"),
        ("sh", "bash"),
        ("json", "json"),
        ("md", "markdown"),
        ("swift", "swift"),
        ("html", "xml"),
        ("css", "css"),
        ("yml", "yaml"),
    ])
    func knowsCommonExtensions(ext: String, language: String) {
        #expect(CodeLanguage.forExtension(ext) == language)
    }

    @Test("Does not care about capitals")
    func ignoresCapitals() {
        #expect(CodeLanguage.forExtension("PY") == "python")
    }

    @Test("Ignores space around the extension")
    func ignoresSpace() {
        #expect(CodeLanguage.forExtension("  js  ") == "javascript")
    }

    @Test("Has nothing to color for plain text")
    func plainTextHasNoLanguage() {
        #expect(CodeLanguage.forExtension("txt") == nil)
    }

    @Test("Has nothing to color for an extension it does not know")
    func unknownHasNoLanguage() {
        #expect(CodeLanguage.forExtension("wibble") == nil)
        #expect(CodeLanguage.forExtension("") == nil)
    }
}
