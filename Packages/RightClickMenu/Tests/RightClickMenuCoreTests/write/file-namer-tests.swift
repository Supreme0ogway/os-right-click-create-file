import Testing

@testable import RightClickMenuCore

@Suite("File namer")
struct FileNamerTests {

    private func nameIn(
        _ taken: Set<String>,
        base: String = "Untitled",
        ext: String = "txt"
    ) throws -> String {
        try FileNamer.firstFreeName(base: base, fileExtension: ext, takenNames: taken)
    }

    @Test("Uses the plain name when nothing is in the way")
    func usesPlainName() throws {
        #expect(try nameIn([]) == "Untitled.txt")
    }

    @Test("Counts up past a name that is taken")
    func countsPastTakenName() throws {
        #expect(try nameIn(["Untitled.txt"]) == "Untitled 2.txt")
    }

    @Test("Keeps counting while the names are taken")
    func keepsCounting() throws {
        let taken: Set<String> = ["Untitled.txt", "Untitled 2.txt", "Untitled 3.txt"]

        #expect(try nameIn(taken) == "Untitled 4.txt")
    }

    @Test("Fills a gap rather than always going to the end")
    func fillsAGap() throws {
        #expect(try nameIn(["Untitled.txt", "Untitled 3.txt"]) == "Untitled 2.txt")
    }

    @Test("Ignores a file whose name only starts the same")
    func ignoresDifferentName() throws {
        #expect(try nameIn(["Untitled notes.txt", "Untitled.md"]) == "Untitled.txt")
    }

    @Test("Leaves out the dot when the type has no extension")
    func leavesOutTheDot() throws {
        #expect(try nameIn([], base: "Makefile", ext: "") == "Makefile")
    }

    @Test("Counts up on a name with no extension too")
    func countsUpWithNoExtension() throws {
        #expect(try nameIn(["Makefile"], base: "Makefile", ext: "") == "Makefile 2")
    }

    @Test("Keeps a dot that is part of the name")
    func keepsDotInsideName() throws {
        #expect(try nameIn([], base: "index.spec", ext: "ts") == "index.spec.ts")
    }

    @Test("Keeps the spaces somebody typed in the name")
    func keepsTypedSpaces() throws {
        #expect(try nameIn([], base: "My Invoice", ext: "md") == "My Invoice.md")
    }

    @Test("Falls back to a usable name when the base is blank")
    func fallsBackOnBlankBase() throws {
        #expect(try nameIn([], base: "   ", ext: "txt") == "Untitled.txt")
    }

    @Test("Counts past a name that differs only by case, because the disk cannot tell them apart")
    func countsPastDifferentCase() throws {
        #expect(try nameIn(["untitled.TXT"]) == "Untitled 2.txt")
    }

    @Test("Refuses a base name holding a slash, which would move the file elsewhere")
    func refusesSlashInBase() {
        #expect(throws: FileNamerError.unusableName) {
            try FileNamer.firstFreeName(base: "../secrets", fileExtension: "txt", takenNames: [])
        }
    }

    @Test("Refuses a base name that is only dots, which names a folder not a file")
    func refusesDotsOnlyBase() {
        #expect(throws: FileNamerError.unusableName) {
            try FileNamer.firstFreeName(base: "..", fileExtension: "", takenNames: [])
        }
    }

    @Test("Gives up rather than counting forever when everything is taken")
    func givesUpEventually() {
        let taken = Set((1...FileNamerConstants.maximumAttempts + 1).map { count in
            count == 1 ? "Untitled.txt" : "Untitled \(count).txt"
        })

        #expect(throws: FileNamerError.noFreeName) {
            try FileNamer.firstFreeName(base: "Untitled", fileExtension: "txt", takenNames: taken)
        }
    }
}
