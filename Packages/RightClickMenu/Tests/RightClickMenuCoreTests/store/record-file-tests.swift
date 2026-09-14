import Foundation
import Testing

@testable import RightClickMenuCore

@Suite("Record file")
struct RecordFileTests {

    private func makeFileURL() throws -> URL {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appending(path: LegendConstants.fileName)
    }

    private func makeLegend() throws -> Legend {
        Legend(types: [
            FileType(
                id: try FileTypeIdentifier("core:plain-text"),
                displayName: "Text File",
                fileExtension: "txt",
                defaultBaseName: "Untitled",
                template: ""
            )
        ])
    }

    @Test("A file that was never written reads as the fallback, not as a failure")
    func missingFileReadsAsFallback() throws {
        let fileURL = try makeFileURL()

        let read = RecordFile.read(from: fileURL, fallback: Legend.empty)

        #expect(read == Legend.empty)
    }

    @Test("Writes a record and reads the same one back")
    func writesAndReadsBack() throws {
        let fileURL = try makeFileURL()
        let legend = try makeLegend()

        try RecordFile.write(legend, to: fileURL)

        #expect(RecordFile.read(from: fileURL, fallback: Legend.empty) == legend)
    }

    @Test("Writes a folder that is not there yet, so a first run works")
    func makesMissingFolder() throws {
        let deep = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)/nested")
            .appending(path: LegendConstants.fileName)

        try RecordFile.write(Legend.empty, to: deep)

        #expect(FileManager.default.fileExists(atPath: deep.path))
    }

    @Test("Writes text a person can read and edit by hand")
    func writesReadableText() throws {
        let fileURL = try makeFileURL()

        try RecordFile.write(try makeLegend(), to: fileURL)

        let text = try String(contentsOf: fileURL, encoding: .utf8)
        #expect(text.contains("\n"))
        #expect(text.contains("\"core:plain-text\""))
    }

    @Test("Damaged text reads as the fallback, so a bad file never stops the app")
    func damagedTextReadsAsFallback() throws {
        let fileURL = try makeFileURL()
        try "{ this is not json".write(to: fileURL, atomically: true, encoding: .utf8)

        let read = RecordFile.read(from: fileURL, fallback: Legend.empty)

        #expect(read == Legend.empty)
    }

    @Test("Replacing a record leaves no trace of the one before")
    func replacingLeavesNoTrace() throws {
        let fileURL = try makeFileURL()
        try RecordFile.write(try makeLegend(), to: fileURL)

        try RecordFile.write(Legend.empty, to: fileURL)

        #expect(RecordFile.read(from: fileURL, fallback: try makeLegend()) == Legend.empty)
    }

    @Test("Works the same for a scope as for a legend")
    func worksForScopeToo() throws {
        let fileURL = try makeFileURL()
        let scope = Scope(places: .folders(["/Users/someone/Notes"]))

        try RecordFile.write(scope, to: fileURL)

        #expect(RecordFile.read(from: fileURL, fallback: Scope.fallback) == scope)
    }
}
