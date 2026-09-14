import Foundation
import Testing

@testable import RightClickMenuShared

@Suite("Scope")
struct ScopeTests {

    @Test("Everywhere watches everything")
    func everywhereWatchesEverything() {
        let scope = Scope.everywhere

        #expect(scope.places == .everywhere)
        #expect(!scope.watchesNothing)
    }

    @Test("A picked folder is watched")
    func picksAFolder() {
        let scope = Scope(places: .folders(["/Users/someone/Projects"]))

        #expect(scope.folderPaths == ["/Users/someone/Projects"])
        #expect(!scope.watchesNothing)
    }

    @Test("Everywhere lists no folders, because it is not a list of folders")
    func everywhereListsNoFolders() {
        #expect(Scope.everywhere.folderPaths.isEmpty)
    }

    @Test("Picking no folders is allowed, and then the menu appears nowhere")
    func noFoldersMeansNowhere() {
        let scope = Scope(places: .folders([]))

        #expect(scope.watchesNothing)
    }

    @Test("Drops a trailing slash, so one folder is never watched twice")
    func dropsTrailingSlash() {
        let scope = Scope(places: .folders(["/Users/someone/Projects/"]))

        #expect(scope.folderPaths == ["/Users/someone/Projects"])
    }

    @Test("Keeps the root on its own, because it is nothing but a slash")
    func keepsRoot() {
        let scope = Scope(places: .folders(["/"]))

        #expect(scope.folderPaths == ["/"])
    }

    @Test("Drops a repeated folder, keeping the order of the first of each")
    func dropsRepeatedFolder() {
        let scope = Scope(places: .folders([
            "/Users/someone/Projects",
            "/Users/someone/Notes",
            "/Users/someone/Projects/",
        ]))

        #expect(scope.folderPaths == ["/Users/someone/Projects", "/Users/someone/Notes"])
    }

    @Test("Drops blank text, which is not a folder")
    func dropsBlankText() {
        let scope = Scope(places: .folders(["  ", "", "/Users/someone/Notes"]))

        #expect(scope.folderPaths == ["/Users/someone/Notes"])
    }

    @Test("Adding a folder puts it at the end and leaves the original alone")
    func addingPutsAtEnd() {
        let scope = Scope(places: .folders(["/Users/someone/Projects"]))

        let grown = scope.addingFolder("/Users/someone/Notes")

        #expect(grown.folderPaths == ["/Users/someone/Projects", "/Users/someone/Notes"])
        #expect(scope.folderPaths.count == 1)
    }

    @Test("Adding a folder to everywhere narrows it to just that folder")
    func addingToEverywhereNarrows() {
        let grown = Scope.everywhere.addingFolder("/Users/someone/Notes")

        #expect(grown.folderPaths == ["/Users/someone/Notes"])
    }

    @Test("Removing a folder leaves the rest and leaves the original alone")
    func removingLeavesRest() {
        let scope = Scope(places: .folders([
            "/Users/someone/Projects",
            "/Users/someone/Notes",
        ]))

        let shrunk = scope.removingFolder("/Users/someone/Projects")

        #expect(shrunk.folderPaths == ["/Users/someone/Notes"])
        #expect(scope.folderPaths.count == 2)
    }

    @Test("Removing the last folder is allowed and leaves the menu nowhere")
    func removingTheLastIsAllowed() {
        let scope = Scope(places: .folders(["/Users/someone/Projects"]))

        let shrunk = scope.removingFolder("/Users/someone/Projects")

        #expect(shrunk.watchesNothing)
    }

    @Test("Everywhere is what an app with nothing set up uses")
    func everywhereIsTheFallback() {
        #expect(Scope.fallback == Scope.everywhere)
    }

    @Test("Survives being written out and read back", arguments: [
        Scope.everywhere,
        Scope(places: .folders(["/Users/someone/Projects", "/Users/someone/Notes"])),
        Scope(places: .folders([])),
    ])
    func survivesRoundTrip(scope: Scope) throws {
        let written = try JSONEncoder().encode(scope)
        let read = try JSONDecoder().decode(Scope.self, from: written)

        #expect(read == scope)
    }

    @Test("Carries its schema version, so a later reader knows what it is holding")
    func carriesVersion() throws {
        let written = try JSONEncoder().encode(Scope.everywhere)

        #expect(String(decoding: written, as: UTF8.self).contains("\"version\""))
    }
}

@Suite("Scope file shape")
struct ScopeFileShapeTests {

    /// Writes the way the app writes these files, slashes and all.
    private func text(for scope: Scope) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        return String(decoding: try encoder.encode(scope), as: UTF8.self)
    }

    @Test("Writes everywhere in words a person can read")
    func writesEverywhereReadably() throws {
        let written = try text(for: .everywhere)

        #expect(written.contains("\"everywhere\""))
        #expect(!written.contains("_0"))
    }

    @Test("Writes a chosen list in words a person can read")
    func writesFoldersReadably() throws {
        let scope = Scope(places: .folders(["/Users/someone/Notes"]))

        let written = try text(for: scope)

        #expect(written.contains("\"folders\""))
        #expect(written.contains("/Users/someone/Notes"))
        #expect(!written.contains("_0"))
    }

    @Test("A file written by hand with a name nobody knows reads as everywhere")
    func unknownNameReadsAsEverywhere() throws {
        let written = Data(#"{"version":1,"places":{"where":"wibble"}}"#.utf8)

        let read = try JSONDecoder().decode(Scope.self, from: written)

        #expect(read.places == .everywhere)
        #expect(!read.watchesNothing)
    }

    @Test("A chosen list with no folders written by hand still means nowhere")
    func handWrittenEmptyListMeansNowhere() throws {
        let written = Data(#"{"version":1,"places":{"where":"folders","folders":[]}}"#.utf8)

        let read = try JSONDecoder().decode(Scope.self, from: written)

        #expect(read.watchesNothing)
    }
}
