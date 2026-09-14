import Foundation
import Testing

@testable import RightClickMenuUI

@MainActor
@Suite("Legend editor view model")
struct LegendEditorViewModelTests {

    private func makeModel(_ types: [FileType] = []) throws -> LegendEditorViewModel {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let store = RecordStore(
            fileURL: folder.appending(path: LegendConstants.fileName),
            fallback: Legend(types: types)
        )
        return LegendEditorViewModel(store: store)
    }

    private func makeType(_ name: String, id: String) throws -> FileType {
        FileType(
            id: try FileTypeIdentifier(id),
            displayName: name,
            fileExtension: "txt",
            defaultBaseName: "Untitled",
            template: ""
        )
    }

    @Test("Shows what the store holds")
    func showsWhatStoreHolds() throws {
        let model = try makeModel([try makeType("Text File", id: "core:plain-text")])

        #expect(model.types.map(\.displayName) == ["Text File"])
    }

    @Test("Adding puts a new type at the end")
    func addingPutsAtEnd() throws {
        let model = try makeModel([try makeType("Text File", id: "core:plain-text")])

        model.addType()

        #expect(model.types.count == 2)
    }

    @Test("Each added type gets an id of its own")
    func addedTypesGetOwnIds() throws {
        let model = try makeModel()

        model.addType()
        model.addType()
        model.addType()

        #expect(Set(model.types.map(\.id)).count == 3)
    }

    @Test("An added type belongs to the user, not to the app")
    func addedTypeBelongsToUser() throws {
        let model = try makeModel()

        model.addType()

        let namespace = model.types.first?.id.namespace
        #expect(namespace?.hasPrefix(IdentifierConstants.userNamespacePrefix) == true)
    }

    @Test("Adding hands back the new id, so the screen can show it at once")
    func addingHandsBackTheId() throws {
        let model = try makeModel()

        let added = model.addType()

        #expect(added != nil)
        #expect(model.types.first?.id == added)
    }

    @Test("Removing takes that type out")
    func removingTakesTypeOut() throws {
        let model = try makeModel([
            try makeType("Text File", id: "core:plain-text"),
            try makeType("Markdown", id: "core:markdown"),
        ])

        model.removeType(try FileTypeIdentifier("core:plain-text"))

        #expect(model.types.map(\.displayName) == ["Markdown"])
    }

    @Test("Removing the very last type is allowed and leaves nothing")
    func removingTheLastIsAllowed() throws {
        let model = try makeModel([try makeType("Text File", id: "core:plain-text")])

        model.removeType(try FileTypeIdentifier("core:plain-text"))

        #expect(model.types.isEmpty)
        #expect(model.showsEmptyMessage)
    }

    @Test("Says nothing about being empty while there is something to show")
    func noEmptyMessageWhenFull() throws {
        let model = try makeModel([try makeType("Text File", id: "core:plain-text")])

        #expect(!model.showsEmptyMessage)
    }

    @Test("A change is kept, so the menu sees it without the app restarting")
    func changeIsKept() throws {
        let model = try makeModel()

        model.addType()

        #expect(model.store.value.types.count == 1)
    }

    @Test("Renaming a type keeps its place in the list")
    func renamingKeepsPlace() throws {
        let model = try makeModel([
            try makeType("Text File", id: "core:plain-text"),
            try makeType("Markdown", id: "core:markdown"),
        ])
        let renamed = try makeType("Plain Text", id: "core:plain-text")

        model.updateType(renamed)

        #expect(model.types.map(\.displayName) == ["Plain Text", "Markdown"])
    }

    @Test("A type with a blank name is shown as not ready, rather than being refused")
    func blankNameIsNotReady() throws {
        let model = try makeModel()
        let blank = FileType(
            id: try FileTypeIdentifier("user.will:new"),
            displayName: "   ",
            fileExtension: "txt",
            defaultBaseName: "Untitled",
            template: ""
        )

        #expect(!model.isReady(blank))
    }

    @Test("A type with a name and an extension is ready")
    func completeTypeIsReady() throws {
        let model = try makeModel()

        #expect(model.isReady(try makeType("Text File", id: "core:plain-text")))
    }

    @Test("Follows the store when something else changes it")
    func followsTheStore() throws {
        let model = try makeModel()

        try model.store.save(Legend(types: [try makeType("Markdown", id: "core:markdown")]))

        #expect(model.types.map(\.displayName) == ["Markdown"])
    }
}

@MainActor
@Suite("Legend editor searching")
struct LegendEditorSearchTests {

    private func makeModel(_ names: [(String, String)]) throws -> LegendEditorViewModel {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let types = try names.map { name, ext in
            FileType(
                id: try FileTypeIdentifier("core:\(ext)"),
                displayName: name,
                fileExtension: ext,
                defaultBaseName: "Untitled",
                template: ""
            )
        }
        let store = RecordStore(
            fileURL: folder.appending(path: LegendConstants.fileName),
            fallback: Legend(types: types)
        )
        return LegendEditorViewModel(store: store)
    }

    private func sample() throws -> LegendEditorViewModel {
        try makeModel([("Markdown File", "md"), ("Python File", "py"), ("JSON File", "json")])
    }

    @Test("An empty search shows everything")
    func emptySearchShowsAll() throws {
        let model = try sample()

        #expect(model.shownTypes.count == 3)
    }

    @Test("A search that is only spaces shows everything")
    func blankSearchShowsAll() throws {
        let model = try sample()

        model.search = "   "

        #expect(model.shownTypes.count == 3)
    }

    @Test("Finds a type by part of its name")
    func findsByName() throws {
        let model = try sample()

        model.search = "pyth"

        #expect(model.shownTypes.map(\.displayName) == ["Python File"])
    }

    @Test("Finds a type by its extension, which is what people remember")
    func findsByExtension() throws {
        let model = try sample()

        model.search = "md"

        #expect(model.shownTypes.map(\.displayName) == ["Markdown File"])
    }

    @Test("Does not care about capitals")
    func ignoresCapitals() throws {
        let model = try sample()

        model.search = "JSON"

        #expect(model.shownTypes.count == 1)
    }

    @Test("Says the search found nothing, which is not the same as having nothing")
    func saysSearchFoundNothing() throws {
        let model = try sample()

        model.search = "nothing here"

        #expect(model.shownTypes.isEmpty)
        #expect(model.showsNoMatchesMessage)
        #expect(!model.showsEmptyMessage)
    }

    @Test("An empty list is not called a search with no matches")
    func emptyListIsNotNoMatches() throws {
        let model = try makeModel([])

        model.search = "anything"

        #expect(model.showsEmptyMessage)
        #expect(!model.showsNoMatchesMessage)
    }

    @Test("Keeps the list's order while searching")
    func keepsOrder() throws {
        let model = try sample()

        model.search = "file"

        let shown = model.shownTypes.map(\.displayName)
        #expect(shown == ["Markdown File", "Python File", "JSON File"])
    }
}
