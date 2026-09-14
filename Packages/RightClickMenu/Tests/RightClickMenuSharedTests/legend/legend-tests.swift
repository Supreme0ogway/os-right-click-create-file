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

@Suite("Legend order")
struct LegendOrderTests {

    private func makeLegend(_ names: [String]) throws -> Legend {
        Legend(types: try names.map { name in
            FileType(
                id: try FileTypeIdentifier("core:\(name)"),
                displayName: name,
                fileExtension: name,
                defaultBaseName: "Untitled",
                template: ""
            )
        })
    }

    private func names(_ legend: Legend) -> [String] {
        legend.types.map(\.displayName)
    }

    @Test("Moves one type down the list")
    func movesDown() throws {
        let legend = try makeLegend(["a", "b", "c"])

        #expect(names(legend.moving(from: [0], to: 2)) == ["b", "a", "c"])
    }

    @Test("Moves one type to the very end")
    func movesToTheEnd() throws {
        let legend = try makeLegend(["a", "b", "c"])

        #expect(names(legend.moving(from: [0], to: 3)) == ["b", "c", "a"])
    }

    @Test("Moves one type up the list")
    func movesUp() throws {
        let legend = try makeLegend(["a", "b", "c"])

        #expect(names(legend.moving(from: [2], to: 0)) == ["c", "a", "b"])
    }

    @Test("Moves several types together, keeping their order")
    func movesSeveral() throws {
        let legend = try makeLegend(["a", "b", "c", "d"])

        #expect(names(legend.moving(from: [0, 1], to: 4)) == ["c", "d", "a", "b"])
    }

    @Test("Leaves the original alone")
    func leavesOriginalAlone() throws {
        let legend = try makeLegend(["a", "b", "c"])

        _ = legend.moving(from: [0], to: 2)

        #expect(names(legend) == ["a", "b", "c"])
    }

    @Test("Moving a type onto itself changes nothing")
    func movingOntoItselfChangesNothing() throws {
        let legend = try makeLegend(["a", "b", "c"])

        #expect(names(legend.moving(from: [1], to: 1)) == ["a", "b", "c"])
    }

    @Test("Moving nothing changes nothing")
    func movingNothingChangesNothing() throws {
        let legend = try makeLegend(["a", "b", "c"])

        #expect(names(legend.moving(from: [], to: 2)) == ["a", "b", "c"])
    }

    @Test("A place that is not there is ignored rather than crashing")
    func outOfRangeIsIgnored() throws {
        let legend = try makeLegend(["a", "b"])

        #expect(names(legend.moving(from: [9], to: 0)) == ["a", "b"])
        #expect(names(legend.moving(from: [0], to: 99)) == ["b", "a"])
    }

    @Test("Moving keeps every type, losing none and repeating none")
    func keepsEveryType() throws {
        let legend = try makeLegend(["a", "b", "c", "d"])

        let moved = legend.moving(from: [1], to: 4)

        #expect(Set(names(moved)) == ["a", "b", "c", "d"])
        #expect(moved.types.count == 4)
    }

    @Test("Moving keeps the schema version")
    func keepsVersion() throws {
        let legend = try makeLegend(["a", "b"])

        #expect(legend.moving(from: [0], to: 2).version == legend.version)
    }
}
