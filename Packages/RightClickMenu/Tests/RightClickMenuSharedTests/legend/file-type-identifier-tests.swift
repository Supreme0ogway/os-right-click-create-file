import Foundation
import Testing

@testable import RightClickMenuShared

@Suite("File type identifier")
struct FileTypeIdentifierTests {

    @Test("Splits a well formed id into its namespace and its name")
    func splitsIntoParts() throws {
        let identifier = try FileTypeIdentifier("core:plain-text")

        #expect(identifier.namespace == "core")
        #expect(identifier.name == "plain-text")
    }

    @Test("Keeps a dotted namespace whole")
    func keepsDottedNamespace() throws {
        let identifier = try FileTypeIdentifier("user.will:invoice")

        #expect(identifier.namespace == "user.will")
        #expect(identifier.name == "invoice")
    }

    @Test("Reads back as the text it was written from")
    func readsBackAsText() throws {
        let identifier = try FileTypeIdentifier("core:plain-text")

        #expect(identifier.text == "core:plain-text")
    }

    @Test("Refuses text with no separator")
    func refusesMissingSeparator() {
        #expect(throws: FileTypeIdentifierError.missingSeparator) {
            try FileTypeIdentifier("plain-text")
        }
    }

    @Test("Refuses an empty namespace")
    func refusesEmptyNamespace() {
        #expect(throws: FileTypeIdentifierError.emptyNamespace) {
            try FileTypeIdentifier(":plain-text")
        }
    }

    @Test("Refuses an empty name")
    func refusesEmptyName() {
        #expect(throws: FileTypeIdentifierError.emptyName) {
            try FileTypeIdentifier("core:")
        }
    }

    @Test("Refuses a second separator, so a name can never hide one")
    func refusesSecondSeparator() {
        #expect(throws: FileTypeIdentifierError.missingSeparator) {
            try FileTypeIdentifier("core:plain:text")
        }
    }

    @Test("Refuses a character that is not allowed in an id", arguments: [
        "core:plain text",
        "core:plain/text",
        "core:plain_text",
        "co re:plain-text",
        "core/sub:plain-text",
    ])
    func refusesInvalidCharacter(text: String) {
        #expect(throws: FileTypeIdentifierError.invalidCharacter) {
            try FileTypeIdentifier(text)
        }
    }

    @Test("Survives being written out and read back")
    func survivesRoundTrip() throws {
        let identifier = try FileTypeIdentifier("user.will:invoice")

        let written = try JSONEncoder().encode(identifier)
        let read = try JSONDecoder().decode(FileTypeIdentifier.self, from: written)

        #expect(read == identifier)
    }

    @Test("Writes itself as a plain string, not as an object")
    func writesAsPlainString() throws {
        let identifier = try FileTypeIdentifier("core:plain-text")

        let written = try JSONEncoder().encode(identifier)

        #expect(String(decoding: written, as: UTF8.self) == "\"core:plain-text\"")
    }

    @Test("Refuses a bad id while being read back, rather than accepting it")
    func refusesBadIdWhenRead() {
        let written = Data("\"no-separator-here\"".utf8)

        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(FileTypeIdentifier.self, from: written)
        }
    }
}
