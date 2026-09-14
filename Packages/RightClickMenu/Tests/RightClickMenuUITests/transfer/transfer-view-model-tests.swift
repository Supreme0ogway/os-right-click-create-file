import Foundation
import Testing

@testable import RightClickMenuUI

@MainActor
@Suite("Transfer view model")
struct TransferViewModelTests {

    private func makeModel(_ types: [FileType] = []) throws -> TransferViewModel {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let store = RecordStore(
            fileURL: folder.appending(path: LegendConstants.fileName),
            fallback: Legend(types: types)
        )
        return TransferViewModel(store: store)
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

    private func write(_ text: String) throws -> URL {
        let fileURL = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString).json")
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data(text.utf8).write(to: fileURL)
        return fileURL
    }

    @Test("Writes the list out to a file")
    func writesOut() throws {
        let model = try makeModel([try makeType("Markdown", id: "core:markdown")])
        let destination = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString).json")
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        model.export(to: destination)

        #expect(FileManager.default.fileExists(atPath: destination.path))
        #expect(model.problem == nil)
    }

    @Test("Reads a list back in and adds it")
    func readsBackIn() throws {
        let model = try makeModel([try makeType("Markdown", id: "core:markdown")])
        let incoming = Legend(types: [try makeType("Invoice", id: "user.will:invoice")])
        let text = String(decoding: try LegendTransfer.data(for: incoming), as: UTF8.self)
        let fileURL = try write(text)

        model.importFrom(fileURL)

        #expect(model.store.value.types.count == 2)
        #expect(model.problem == nil)
    }

    @Test("Says the file is damaged rather than doing nothing")
    func saysFileIsDamaged() throws {
        let model = try makeModel([try makeType("Markdown", id: "core:markdown")])
        let fileURL = try write("{ this is not a list of file types")

        model.importFrom(fileURL)

        #expect(model.problem == UIText.fileIsDamaged)
    }

    @Test("Leaves the list alone when the file is damaged")
    func leavesListAloneOnDamage() throws {
        let model = try makeModel([try makeType("Markdown", id: "core:markdown")])
        let fileURL = try write("nonsense")

        model.importFrom(fileURL)

        #expect(model.store.value.types.count == 1)
    }

    @Test("Says the file is damaged when it is not there at all")
    func saysDamagedWhenMissing() throws {
        let model = try makeModel()
        let missing = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).json")

        model.importFrom(missing)

        #expect(model.problem == UIText.fileIsDamaged)
    }

    @Test("Clearing the problem takes the message away")
    func clearingTakesMessageAway() throws {
        let model = try makeModel()
        model.importFrom(try write("nonsense"))

        model.clearProblem()

        #expect(model.problem == nil)
    }

    @Test("A good file after a bad one clears the message")
    func goodFileClearsMessage() throws {
        let model = try makeModel()
        model.importFrom(try write("nonsense"))
        let empty = String(decoding: try LegendTransfer.data(for: .empty), as: UTF8.self)
        let good = try write(empty)

        model.importFrom(good)

        #expect(model.problem == nil)
    }

    @Test("Suggests a name for the file it writes out")
    func suggestsAName() throws {
        #expect(try makeModel().suggestedFileName == LegendTransfer.suggestedFileName)
    }
}
