import Foundation
import Testing

@testable import RightClickMenuUI

@MainActor
@Suite("Scope picker view model")
struct ScopePickerViewModelTests {

    private func makeModel(_ scope: Scope = .everywhere) throws -> ScopePickerViewModel {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let store = RecordStore(
            fileURL: folder.appending(path: ScopeConstants.fileName),
            fallback: scope
        )
        return ScopePickerViewModel(store: store)
    }

    @Test("Starts on everywhere, which is what a fresh app uses")
    func startsOnEverywhere() throws {
        let model = try makeModel()

        #expect(model.isEverywhere)
        #expect(model.folderPaths.isEmpty)
    }

    @Test("Shows the folders that were picked")
    func showsPickedFolders() throws {
        let model = try makeModel(Scope(places: .folders(["/Users/someone/Notes"])))

        #expect(!model.isEverywhere)
        #expect(model.folderPaths == ["/Users/someone/Notes"])
    }

    @Test("Switching to picked folders starts with an empty list")
    func switchingStartsEmpty() throws {
        let model = try makeModel()

        model.usePickedFolders()

        #expect(!model.isEverywhere)
        #expect(model.folderPaths.isEmpty)
    }

    @Test("Switching back to everywhere forgets the folders")
    func switchingBackForgetsFolders() throws {
        let model = try makeModel(Scope(places: .folders(["/Users/someone/Notes"])))

        model.useEverywhere()

        #expect(model.isEverywhere)
        #expect(model.folderPaths.isEmpty)
    }

    @Test("Adding a folder puts it in the list")
    func addingPutsInList() throws {
        let model = try makeModel()

        model.addFolder(URL(filePath: "/Users/someone/Notes"))

        #expect(model.folderPaths == ["/Users/someone/Notes"])
        #expect(!model.isEverywhere)
    }

    @Test("Adding the same folder twice keeps one")
    func addingTwiceKeepsOne() throws {
        let model = try makeModel()

        model.addFolder(URL(filePath: "/Users/someone/Notes"))
        model.addFolder(URL(filePath: "/Users/someone/Notes"))

        #expect(model.folderPaths == ["/Users/someone/Notes"])
    }

    @Test("Removing a folder takes it out")
    func removingTakesOut() throws {
        let model = try makeModel(Scope(places: .folders([
            "/Users/someone/Notes",
            "/Users/someone/Projects",
        ])))

        model.removeFolder("/Users/someone/Notes")

        #expect(model.folderPaths == ["/Users/someone/Projects"])
    }

    @Test("Removing the last folder is allowed, and warns the menu now appears nowhere")
    func removingTheLastWarns() throws {
        let model = try makeModel(Scope(places: .folders(["/Users/someone/Notes"])))

        model.removeFolder("/Users/someone/Notes")

        #expect(model.folderPaths.isEmpty)
        #expect(model.showsNowhereWarning)
    }

    @Test("Says nothing about nowhere while on everywhere")
    func noWarningOnEverywhere() throws {
        #expect(!(try makeModel().showsNowhereWarning))
    }

    @Test("A change is kept, so the extension sees it")
    func changeIsKept() throws {
        let model = try makeModel()

        model.addFolder(URL(filePath: "/Users/someone/Notes"))

        #expect(model.store.value.folderPaths == ["/Users/someone/Notes"])
    }

    @Test("Follows the store when something else changes it")
    func followsTheStore() throws {
        let model = try makeModel()

        try model.store.save(Scope(places: .folders(["/Users/someone/Projects"])))

        #expect(model.folderPaths == ["/Users/someone/Projects"])
    }
}
