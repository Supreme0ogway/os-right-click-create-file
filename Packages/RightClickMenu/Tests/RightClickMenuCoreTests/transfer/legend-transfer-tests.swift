import Foundation
import Testing

@testable import RightClickMenuCore

@Suite("Legend transfer")
struct LegendTransferTests {

    private func makeType(_ name: String, id: String, ext: String = "txt") throws -> FileType {
        FileType(
            id: try FileTypeIdentifier(id),
            displayName: name,
            fileExtension: ext,
            defaultBaseName: "Untitled",
            template: ""
        )
    }

    @Test("What is written out reads back as the same list")
    func survivesRoundTrip() throws {
        let legend = Legend(types: [
            try makeType("Markdown", id: "core:markdown", ext: "md"),
            try makeType("Invoice", id: "user.will:invoice", ext: "txt"),
        ])

        let written = try LegendTransfer.data(for: legend)
        let read = try LegendTransfer.legend(from: written)

        #expect(read == legend)
    }

    @Test("Writes text a person can read")
    func writesReadableText() throws {
        let legend = Legend(types: [try makeType("Markdown", id: "core:markdown", ext: "md")])

        let text = String(decoding: try LegendTransfer.data(for: legend), as: UTF8.self)

        #expect(text.contains("\n"))
        #expect(text.contains("core:markdown"))
    }

    @Test("An empty list can be written out and read back")
    func emptyRoundTrips() throws {
        let written = try LegendTransfer.data(for: .empty)

        #expect(try LegendTransfer.legend(from: written).isEmpty)
    }

    @Test("Refuses text that is not json at all")
    func refusesNotJSON() {
        #expect(throws: LegendTransferError.cannotBeRead) {
            try LegendTransfer.legend(from: Data("this is not json".utf8))
        }
    }

    @Test("Refuses json that is not a list of file types")
    func refusesWrongShape() {
        #expect(throws: LegendTransferError.cannotBeRead) {
            try LegendTransfer.legend(from: Data(#"{"hello": "world"}"#.utf8))
        }
    }

    @Test("Refuses a file that has been cut off part way")
    func refusesTruncated() throws {
        let written = try LegendTransfer.data(for: Legend(types: [
            try makeType("Markdown", id: "core:markdown", ext: "md"),
        ]))
        let half = written.prefix(written.count / 2)

        #expect(throws: LegendTransferError.cannotBeRead) {
            try LegendTransfer.legend(from: Data(half))
        }
    }

    @Test("Refuses an empty file")
    func refusesEmptyFile() {
        #expect(throws: LegendTransferError.cannotBeRead) {
            try LegendTransfer.legend(from: Data())
        }
    }

    @Test("Refuses a list holding an id that is not an id")
    func refusesBadId() {
        let type = #"{"id":"nonsense","displayName":"X","fileExtension":"txt"#
            + #"","defaultBaseName":"U","template":""}"#
        let broken = Data((#"{"version":1,"types":["# + type + "]}").utf8)

        #expect(throws: LegendTransferError.cannotBeRead) {
            try LegendTransfer.legend(from: broken)
        }
    }

    @Test("Bringing a list in adds to what is there rather than wiping it")
    func importAddsRatherThanWipes() throws {
        let mine = Legend(types: [try makeType("Markdown", id: "core:markdown", ext: "md")])
        let theirs = Legend(types: [try makeType("Invoice", id: "user.will:invoice")])

        let joined = LegendTransfer.joining(theirs, into: mine)

        #expect(joined.types.map(\.id.text) == ["core:markdown", "user.will:invoice"])
    }

    @Test("A type coming in replaces the one it shares an id with, keeping its place")
    func importReplacesSameId() throws {
        let mine = Legend(types: [
            try makeType("Old Name", id: "core:markdown", ext: "md"),
            try makeType("Invoice", id: "user.will:invoice"),
        ])
        let theirs = Legend(types: [try makeType("New Name", id: "core:markdown", ext: "markdown")])

        let joined = LegendTransfer.joining(theirs, into: mine)

        #expect(joined.types.count == 2)
        let markdown = joined.type(withId: try FileTypeIdentifier("core:markdown"))
        #expect(markdown?.displayName == "New Name")
        #expect(joined.types.first?.id.text == "core:markdown")
    }

    @Test("Bringing in an empty list changes nothing")
    func importingNothingChangesNothing() throws {
        let mine = Legend(types: [try makeType("Markdown", id: "core:markdown", ext: "md")])

        #expect(LegendTransfer.joining(.empty, into: mine) == mine)
    }

    @Test("Suggests a file name to write out to")
    func suggestsAFileName() {
        #expect(LegendTransfer.suggestedFileName.hasSuffix(".json"))
    }
}
