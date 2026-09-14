import Foundation
import Testing

@testable import RightClickMenuCore

@MainActor
@Suite("Record store")
struct RecordStoreTests {

    private func makeFileURL() throws -> URL {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appending(path: LegendConstants.fileName)
    }

    private func makeType(_ name: String) throws -> FileType {
        FileType(
            id: try FileTypeIdentifier("core:\(name)"),
            displayName: name,
            fileExtension: "txt",
            defaultBaseName: "Untitled",
            template: ""
        )
    }

    @Test("A store nobody has saved to answers like an empty one")
    func absentAnswersEmpty() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)

        #expect(store.value == Legend.empty)
    }

    @Test("Reads what was already on disk when it starts")
    func readsExistingFile() throws {
        let fileURL = try makeFileURL()
        let legend = Legend(types: [try makeType("markdown")])
        try RecordFile.write(legend, to: fileURL)

        let store = RecordStore(fileURL: fileURL, fallback: Legend.empty)

        #expect(store.value == legend)
    }

    @Test("Saving changes what the store answers with")
    func savingChangesValue() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)
        let legend = Legend(types: [try makeType("markdown")])

        try store.save(legend)

        #expect(store.value == legend)
    }

    @Test("Saving puts it on disk, where the Finder extension will find it")
    func savingWritesToDisk() throws {
        let fileURL = try makeFileURL()
        let store = RecordStore(fileURL: fileURL, fallback: Legend.empty)
        let legend = Legend(types: [try makeType("markdown")])

        try store.save(legend)

        #expect(RecordFile.read(from: fileURL, fallback: Legend.empty) == legend)
    }

    @Test("Tells a new subscriber what the value is right now")
    func tellsNewSubscriberAtOnce() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)
        var heard: [Legend] = []

        let subscription = store.subscribe { heard.append($0) }

        #expect(heard == [Legend.empty])
        subscription.cancel()
    }

    @Test("Tells every subscriber about a change")
    func tellsEverySubscriber() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)
        let legend = Legend(types: [try makeType("markdown")])
        var first: [Legend] = []
        var second: [Legend] = []
        let one = store.subscribe { first.append($0) }
        let two = store.subscribe { second.append($0) }

        try store.save(legend)

        #expect(first == [Legend.empty, legend])
        #expect(second == [Legend.empty, legend])
        one.cancel()
        two.cancel()
    }

    @Test("Stops telling a subscriber that cancelled")
    func stopsAfterCancel() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)
        var heard: [Legend] = []
        let subscription = store.subscribe { heard.append($0) }

        subscription.cancel()
        try store.save(Legend(types: [try makeType("markdown")]))

        #expect(heard == [Legend.empty])
    }

    @Test("Cancelling twice is allowed and changes nothing")
    func cancellingTwiceIsFine() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)
        let subscription = store.subscribe { _ in }

        subscription.cancel()
        subscription.cancel()

        #expect(store.subscriberCount == 0)
    }

    @Test("Letting go of a subscription stops it, so nothing leaks")
    func droppingSubscriptionStopsIt() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)

        do {
            let subscription = store.subscribe { _ in }
            #expect(store.subscriberCount == 1)
            _ = subscription
        }

        #expect(store.subscriberCount == 0)
    }

    @Test("Reloading picks up a change another process made")
    func reloadingPicksUpOutsideChange() throws {
        let fileURL = try makeFileURL()
        let store = RecordStore(fileURL: fileURL, fallback: Legend.empty)
        let legend = Legend(types: [try makeType("markdown")])
        var heard: [Legend] = []
        let subscription = store.subscribe { heard.append($0) }

        try RecordFile.write(legend, to: fileURL)
        store.reload()

        #expect(store.value == legend)
        #expect(heard == [Legend.empty, legend])
        subscription.cancel()
    }

    @Test("Reloading when nothing changed tells nobody, so no needless redraw")
    func reloadingUnchangedTellsNobody() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Legend.empty)
        var heard: [Legend] = []
        let subscription = store.subscribe { heard.append($0) }

        store.reload()

        #expect(heard == [Legend.empty])
        subscription.cancel()
    }

    @Test("Works the same for a scope as for a legend")
    func worksForScopeToo() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: Scope.fallback)

        try store.save(Scope(places: .folders(["/Users/someone/Notes"])))

        #expect(store.value.folderPaths == ["/Users/someone/Notes"])
    }
}
