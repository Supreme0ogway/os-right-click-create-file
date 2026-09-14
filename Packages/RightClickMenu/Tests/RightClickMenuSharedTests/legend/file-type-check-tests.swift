import Testing

@testable import RightClickMenuShared

@Suite("File type check")
struct FileTypeCheckTests {

    @Test("A plain extension is fine", arguments: ["txt", "md", "tar", "Rmd", "h5"])
    func plainExtensionIsFine(text: String) {
        #expect(FileTypeCheck.extensionProblem(text) == nil)
    }

    @Test("An empty extension is missing")
    func emptyExtensionIsMissing() {
        #expect(FileTypeCheck.extensionProblem("") == .missing)
        #expect(FileTypeCheck.extensionProblem("   ") == .missing)
    }

    @Test("An extension holding a dot is refused", arguments: [".txt", "tar.gz", "txt."])
    func dotIsRefused(text: String) {
        #expect(FileTypeCheck.extensionProblem(text) == .holdsDot)
    }

    @Test("An extension holding a space is refused", arguments: ["my txt", "a b"])
    func spaceInsideIsRefused(text: String) {
        #expect(FileTypeCheck.extensionProblem(text) == .holdsSpace)
    }

    @Test("Space around an extension is not a fault, it is just trimmed")
    func spaceAroundIsFine() {
        #expect(FileTypeCheck.extensionProblem("  txt  ") == nil)
        #expect(FileTypeCheck.tidied("  txt  ") == "txt")
    }

    @Test("An extension that would send the file elsewhere is refused", arguments: ["a/b", "a:b"])
    func pathCharactersRefused(text: String) {
        #expect(FileTypeCheck.extensionProblem(text) == .holdsPathCharacter)
    }

    @Test("A plain name is fine")
    func plainNameIsFine() {
        #expect(FileTypeCheck.nameProblem("Markdown File") == nil)
    }

    @Test("A name with spaces inside is fine, because names are words")
    func nameKeepsInnerSpaces() {
        #expect(FileTypeCheck.nameProblem("My Invoice Template") == nil)
    }

    @Test("An empty name is missing")
    func emptyNameIsMissing() {
        #expect(FileTypeCheck.nameProblem("") == .missing)
        #expect(FileTypeCheck.nameProblem("  \t ") == .missing)
    }

    @Test("A file name that would move the file is refused", arguments: ["../x", "a/b", "a:b"])
    func baseNamePathCharactersRefused(text: String) {
        #expect(FileTypeCheck.baseNameProblem(text) == .holdsPathCharacter)
    }

    @Test("An ordinary file name is fine")
    func ordinaryBaseNameIsFine() {
        #expect(FileTypeCheck.baseNameProblem("Untitled") == nil)
        #expect(FileTypeCheck.baseNameProblem("My Notes") == nil)
    }

    @Test("An empty file name is missing")
    func emptyBaseNameIsMissing() {
        #expect(FileTypeCheck.baseNameProblem(" ") == .missing)
    }

    @Test("Tidying takes the space off both ends and leaves the middle alone")
    func tidyingTrimsEnds() {
        #expect(FileTypeCheck.tidied("  My Invoice  ") == "My Invoice")
    }
}
