import Foundation
import Testing

@testable import RightClickMenuCore

@Suite("File writer")
struct FileWriterTests {

    private let writer = FileWriter()

    private func makeType(
        name: String = "Text File",
        ext: String = "txt",
        base: String = "Untitled",
        template: String = ""
    ) throws -> FileType {
        FileType(
            id: try FileTypeIdentifier("core:plain-text"),
            displayName: name,
            fileExtension: ext,
            defaultBaseName: base,
            template: template
        )
    }

    private func makeFolder() throws -> URL {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    @Test("Writes a file and says where it put it")
    func writesAFile() throws {
        let folder = try makeFolder()

        let written = try writer.createFile(ofType: try makeType(), in: folder)

        #expect(written.lastPathComponent == "Untitled.txt")
        #expect(FileManager.default.fileExists(atPath: written.path))
    }

    @Test("Puts the template inside the new file")
    func putsTemplateInside() throws {
        let folder = try makeFolder()
        let type = try makeType(ext: "md", template: "# Title\n")

        let written = try writer.createFile(ofType: type, in: folder)

        #expect(try String(contentsOf: written, encoding: .utf8) == "# Title\n")
    }

    @Test("An empty template makes an empty file, which is normal")
    func emptyTemplateMakesEmptyFile() throws {
        let folder = try makeFolder()

        let written = try writer.createFile(ofType: try makeType(), in: folder)

        #expect(try String(contentsOf: written, encoding: .utf8).isEmpty)
    }

    @Test("Never treads on a file already there")
    func neverTreadsOnExistingFile() throws {
        let folder = try makeFolder()
        let type = try makeType(template: "new")
        let existing = folder.appending(path: "Untitled.txt")
        try "original".write(to: existing, atomically: true, encoding: .utf8)

        let written = try writer.createFile(ofType: type, in: folder)

        #expect(written.lastPathComponent == "Untitled 2.txt")
        let original = folder.appending(path: "Untitled.txt")
        #expect(try String(contentsOf: original, encoding: .utf8) == "original")
    }

    @Test("Counts up again on the next one, so three in a row all survive")
    func countsUpEachTime() throws {
        let folder = try makeFolder()
        let type = try makeType()

        let names = try (0..<3).map { _ in
            try writer.createFile(ofType: type, in: folder).lastPathComponent
        }

        #expect(names == ["Untitled.txt", "Untitled 2.txt", "Untitled 3.txt"])
    }

    @Test("Says the folder is missing rather than making one")
    func saysFolderIsMissing() throws {
        let missing = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")

        #expect(throws: FileWriterError.folderIsMissing) {
            try writer.createFile(ofType: try makeType(), in: missing)
        }
    }

    @Test("Says the target is not a folder when it is a file")
    func saysTargetIsNotAFolder() throws {
        let folder = try makeFolder()
        let file = folder.appending(path: "notes.txt")
        try "".write(to: file, atomically: true, encoding: .utf8)

        #expect(throws: FileWriterError.notAFolder) {
            try writer.createFile(ofType: try makeType(), in: file)
        }
    }

    @Test("Writes a file with no extension when the type has none")
    func writesWithNoExtension() throws {
        let folder = try makeFolder()

        let written = try writer.createFile(
            ofType: try makeType(ext: "", base: "Makefile"),
            in: folder
        )

        #expect(written.lastPathComponent == "Makefile")
    }

    @Test("Leaves the folder alone apart from the one file it wrote")
    func leavesFolderAlone() throws {
        let folder = try makeFolder()
        let existing = folder.appending(path: "existing.md")
        try "keep".write(to: existing, atomically: true, encoding: .utf8)

        _ = try writer.createFile(ofType: try makeType(), in: folder)

        let names = try FileManager.default.contentsOfDirectory(atPath: folder.path).sorted()
        #expect(names == ["Untitled.txt", "existing.md"])
    }
}
