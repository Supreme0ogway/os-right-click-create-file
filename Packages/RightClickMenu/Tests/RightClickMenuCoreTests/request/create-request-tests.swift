import Foundation
import Testing

@testable import RightClickMenuCore

@Suite("Create request")
struct CreateRequestTests {

    private func makeRequest(
        _ id: String = "core:plain-text",
        folder: String = "/Users/someone/Notes"
    ) throws -> CreateRequest {
        CreateRequest(typeId: try FileTypeIdentifier(id), folderPath: folder)
    }

    @Test("Turns into an address and back into the same request")
    func survivesRoundTrip() throws {
        let request = try makeRequest()

        let read = CreateRequest(url: request.url)

        #expect(read == request)
    }

    @Test("Uses the app's own scheme, so only this app is asked to handle it")
    func usesOwnScheme() throws {
        let request = try makeRequest()

        #expect(request.url.scheme == BundleConstants.urlScheme)
    }

    @Test("Carries a folder with a space in it", arguments: [
        "/Users/someone/My Notes",
        "/Users/someone/Notes & Things",
        "/Users/someone/Ideas (2026)",
        "/Users/someone/café",
        "/Users/someone/a+b",
        "/Users/someone/100% done",
    ])
    func carriesAwkwardFolder(folder: String) throws {
        let request = try makeRequest(folder: folder)

        #expect(CreateRequest(url: request.url)?.folderPath == folder)
    }

    @Test("Carries a type id with a dotted namespace")
    func carriesDottedNamespace() throws {
        let request = try makeRequest("user.will:invoice")

        #expect(CreateRequest(url: request.url)?.typeId.text == "user.will:invoice")
    }

    @Test("Refuses an address belonging to something else")
    func refusesForeignScheme() throws {
        let foreign = "https://example.com/create?type=core:plain-text&folder=/tmp"
        let url = try #require(URL(string: foreign))

        #expect(CreateRequest(url: url) == nil)
    }

    @Test("Refuses an address asking for something other than creating a file")
    func refusesUnknownAction() throws {
        let wrongAction = "\(BundleConstants.urlScheme)://destroy?type=core:x&folder=/tmp"
        let url = try #require(URL(string: wrongAction))

        #expect(CreateRequest(url: url) == nil)
    }

    @Test("Refuses an address with a part missing", arguments: [
        "create?folder=/Users/someone/Notes",
        "create?type=core:plain-text",
        "create",
    ])
    func refusesMissingParts(tail: String) throws {
        let url = try #require(URL(string: "\(BundleConstants.urlScheme)://\(tail)"))

        #expect(CreateRequest(url: url) == nil)
    }

    @Test("Refuses an address whose type id is not an id at all")
    func refusesBadTypeId() throws {
        let url = try #require(
            URL(string: "\(BundleConstants.urlScheme)://create?type=nonsense&folder=/tmp")
        )

        #expect(CreateRequest(url: url) == nil)
    }

    @Test("Refuses a folder that is not an absolute path, which could point anywhere")
    func refusesRelativeFolder() throws {
        let url = try #require(
            URL(string: "\(BundleConstants.urlScheme)://create?type=core:plain-text&folder=Notes")
        )

        #expect(CreateRequest(url: url) == nil)
    }
}
