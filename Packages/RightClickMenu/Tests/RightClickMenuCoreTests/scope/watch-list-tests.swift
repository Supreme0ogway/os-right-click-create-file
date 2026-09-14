import Foundation
import Testing

@testable import RightClickMenuCore

@Suite("Watch list")
struct WatchListTests {

    @Test("Everywhere watches the top of the disk")
    func everywhereWatchesTheTop() {
        let watched = WatchList.folderURLs(for: .everywhere, volumeRoots: [])

        #expect(Set(watched.map(\.path)) == ["/"])
    }

    @Test("Everywhere also watches each plugged in drive, which the top does not cover")
    func everywhereWatchesVolumes() {
        let drive = URL(filePath: "/Volumes/Backup")

        let watched = WatchList.folderURLs(for: .everywhere, volumeRoots: [drive])

        #expect(Set(watched.map(\.path)) == ["/", "/Volumes/Backup"])
    }

    @Test("Picked folders are watched and nothing else is")
    func picksWatchOnlyThemselves() {
        let scope = Scope(places: .folders(["/Users/someone/Notes", "/Users/someone/Projects"]))

        let drive = URL(filePath: "/Volumes/Backup")
        let watched = WatchList.folderURLs(for: scope, volumeRoots: [drive])

        #expect(Set(watched.map(\.path)) == ["/Users/someone/Notes", "/Users/someone/Projects"])
    }

    @Test("Picking no folders watches nothing, so the menu appears nowhere")
    func noFoldersWatchNothing() {
        let watched = WatchList.folderURLs(for: Scope(places: .folders([])), volumeRoots: [])

        #expect(watched.isEmpty)
    }

    @Test("Hands back a set, because the Finder is told a set of folders")
    func handsBackASet() {
        let watched = WatchList.folderURLs(for: .everywhere, volumeRoots: [URL(filePath: "/")])

        #expect(watched.count == 1)
    }
}
