import Foundation
import Testing

@testable import RightClickMenuShared

@Suite("Legend")
struct LegendTests {

    private func makeType(
        _ id: String,
        name: String = "Text File",
        fileExtension: String = "txt"
    ) throws -> FileType {
        FileType(
            id: try FileTypeIdentifier(id),
            displayName: name,
            fileExtension: fileExtension,
            defaultBaseName: "Untitled",
            template: ""
        )
    }

    @Test("An empty legend is a normal legend, not a broken one")
    func emptyIsNormal() {
        let legend = Legend.empty

        #expect(legend.types.isEmpty)
        #expect(legend.version == LegendConstants.schemaVersion)
    }

    @Test("Keeps the order the types were given in, so the menu does not reshuffle")
    func keepsGivenOrder() throws {
        let legend = Legend(types: [
            try makeType("core:markdown", name: "Markdown"),
            try makeType("core:plain-text", name: "Text File"),
        ])

        #expect(legend.types.map(\.displayName) == ["Markdown", "Text File"])
    }

    @Test("Drops a repeated id, keeping the first, so one id is always one type")
    func dropsRepeatedId() throws {
        let legend = Legend(types: [
            try makeType("core:plain-text", name: "First"),
            try makeType("core:plain-text", name: "Second"),
        ])

        #expect(legend.types.count == 1)
        #expect(legend.types.first?.displayName == "First")
    }

    @Test("Finds a type by its id")
    func findsById() throws {
        let legend = Legend(types: [try makeType("core:plain-text")])

        #expect(legend.type(withId: try FileTypeIdentifier("core:plain-text")) != nil)
        #expect(legend.type(withId: try FileTypeIdentifier("core:markdown")) == nil)
    }

    @Test("Adding a type puts it at the end and leaves the original alone")
    func addingPutsAtEnd() throws {
        let legend = Legend(types: [try makeType("core:plain-text", name: "Text File")])

        let grown = legend.adding(try makeType("core:markdown", name: "Markdown"))

        #expect(grown.types.map(\.displayName) == ["Text File", "Markdown"])
        #expect(legend.types.count == 1)
    }

    @Test("Adding a type that is already there replaces it rather than repeating it")
    func addingReplacesSameId() throws {
        let legend = Legend(types: [try makeType("core:plain-text", name: "Old")])

        let grown = legend.adding(try makeType("core:plain-text", name: "New"))

        #expect(grown.types.count == 1)
        #expect(grown.types.first?.displayName == "New")
    }

    @Test("Removing a type leaves the rest in order and leaves the original alone")
    func removingLeavesRest() throws {
        let legend = Legend(types: [
            try makeType("core:plain-text", name: "Text File"),
            try makeType("core:markdown", name: "Markdown"),
        ])

        let shrunk = legend.removing(try FileTypeIdentifier("core:plain-text"))

        #expect(shrunk.types.map(\.displayName) == ["Markdown"])
        #expect(legend.types.count == 2)
    }

    @Test("Removing the last type is allowed and leaves an empty legend")
    func removingTheLastIsAllowed() throws {
        let legend = Legend(types: [try makeType("core:plain-text")])

        let shrunk = legend.removing(try FileTypeIdentifier("core:plain-text"))

        #expect(shrunk.types.isEmpty)
        #expect(shrunk.isEmpty)
    }

    @Test("Removing an id that is not there changes nothing")
    func removingUnknownChangesNothing() throws {
        let legend = Legend(types: [try makeType("core:plain-text")])

        let shrunk = legend.removing(try FileTypeIdentifier("core:markdown"))

        #expect(shrunk.types.count == 1)
    }

    @Test("Survives being written out and read back")
    func survivesRoundTrip() throws {
        let legend = Legend(types: [
            try makeType("core:plain-text", name: "Text File", fileExtension: "txt"),
            try makeType("user.will:invoice", name: "Invoice", fileExtension: "md"),
        ])

        let written = try JSONEncoder().encode(legend)
        let read = try JSONDecoder().decode(Legend.self, from: written)

        #expect(read == legend)
    }

    @Test("Carries its schema version, so a later reader knows what it is holding")
    func carriesVersion() throws {
        let legend = Legend(types: [try makeType("core:plain-text")])

        let written = try JSONEncoder().encode(legend)
        let asText = String(decoding: written, as: UTF8.self)

        #expect(asText.contains("\"version\""))
    }

    @Test("Reads a legend written by a version it does not know, rather than refusing it")
    func readsUnknownVersion() throws {
        let written = Data("""
        {"version": 999, "types": []}
        """.utf8)

        let read = try JSONDecoder().decode(Legend.self, from: written)

        #expect(read.version == 999)
        #expect(read.types.isEmpty)
    }
}
