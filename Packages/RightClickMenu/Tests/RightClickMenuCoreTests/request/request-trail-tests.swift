import Foundation
import Testing

@testable import RightClickMenuCore

@Suite("Request trail")
struct RequestTrailTests {

    @Test("Keeps what it was told")
    func keepsWhatItWasTold() {
        let trail = RequestTrail(
            typeId: "core:markdown",
            folderPath: "/Users/someone/Notes",
            menuKind: 1,
            handedOver: true,
            note: ""
        )

        #expect(trail.typeId == "core:markdown")
        #expect(trail.folderPath == "/Users/someone/Notes")
        #expect(trail.handedOver)
    }

    @Test("Survives being written out and read back")
    func survivesRoundTrip() throws {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let fileURL = folder.appending(path: TrailConstants.fileName)
        let trail = RequestTrail(
            typeId: "core:markdown",
            folderPath: "/Users/someone/Notes",
            menuKind: 1,
            handedOver: false,
            note: "the Finder named no folder"
        )

        try RecordFile.write(trail, to: fileURL)
        let read = RecordFile.read(from: fileURL, fallback: nil as RequestTrail?)

        #expect(read?.note == "the Finder named no folder")
    }
}
