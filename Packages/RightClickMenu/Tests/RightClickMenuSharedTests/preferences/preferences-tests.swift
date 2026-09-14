import Foundation
import Testing

@testable import RightClickMenuShared

@Suite("Preferences")
struct PreferencesTests {

    @Test("An app nobody has set up starts on plain text")
    func fallbackIsPlainText() {
        #expect(Preferences.fallback.defaultKind == .known(DefaultsConstants.fallbackExtension))
        #expect(Preferences.fallback.version == PreferencesConstants.schemaVersion)
    }

    @Test("Choosing a kind gives a new set, leaving the first alone")
    func choosingLeavesOriginal() {
        let before = Preferences.fallback

        let after = before.startingWith(.known("md"))

        #expect(after.defaultKind == .known("md"))
        #expect(before.defaultKind == .known(DefaultsConstants.fallbackExtension))
    }

    @Test("Custom can be chosen as the starting kind")
    func customCanBeChosen() {
        #expect(Preferences.fallback.startingWith(.custom("")).defaultKind == .custom(""))
    }

    @Test("Keeps the version it was written with")
    func keepsVersion() {
        let changed = Preferences(version: 7, defaultKind: .custom("")).startingWith(.known("py"))

        #expect(changed.version == 7)
    }

    @Test("Survives being written out and read back", arguments: [
        DefaultKind.known("md"),
        DefaultKind.known("txt"),
        DefaultKind.custom(""),
        DefaultKind.custom("conf"),
    ])
    func survivesRoundTrip(kind: DefaultKind) throws {
        let preferences = Preferences.fallback.startingWith(kind)

        let written = try JSONEncoder().encode(preferences)
        let read = try JSONDecoder().decode(Preferences.self, from: written)

        #expect(read == preferences)
    }

    @Test("Carries its schema version, so a later reader knows what it is holding")
    func carriesVersion() throws {
        let written = try JSONEncoder().encode(Preferences.fallback)

        #expect(String(decoding: written, as: UTF8.self).contains("\"version\""))
    }

    @Test("A known kind and custom are never the same thing")
    func knownIsNotCustom() {
        #expect(DefaultKind.known("txt") != DefaultKind.custom("txt"))
    }

    @Test("Writes a known kind in words a person can read")
    func writesKnownReadably() throws {
        let written = try JSONEncoder().encode(Preferences.fallback.startingWith(.known("md")))
        let text = String(decoding: written, as: UTF8.self)

        #expect(text.contains("\"known\""))
        #expect(text.contains("\"md\""))
        #expect(!text.contains("_0"))
    }

    @Test("Writes custom in words a person can read")
    func writesCustomReadably() throws {
        let written = try JSONEncoder().encode(Preferences.fallback.startingWith(.custom("")))
        let text = String(decoding: written, as: UTF8.self)

        #expect(text.contains("\"custom\""))
        #expect(!text.contains("_0"))
    }

    @Test("A choice written by hand with no extension reads as custom")
    func handWrittenWithoutExtensionIsCustom() throws {
        let written = Data(#"{"version":1,"defaultKind":{"kind":"known"}}"#.utf8)

        let read = try JSONDecoder().decode(Preferences.self, from: written)

        #expect(read.defaultKind == .custom(""))
    }

    @Test("A remembered custom extension is written out and read back")
    func customExtensionRoundTrips() throws {
        let preferences = Preferences.fallback.startingWith(.custom("conf"))

        let written = try JSONEncoder().encode(preferences)
        let read = try JSONDecoder().decode(Preferences.self, from: written)

        #expect(read.defaultKind == .custom("conf"))
    }

    @Test("A blank custom extension is left out of the file rather than written empty")
    func blankCustomIsLeftOut() throws {
        let written = try JSONEncoder().encode(Preferences.fallback.startingWith(.custom("")))

        #expect(!String(decoding: written, as: UTF8.self).contains("fileExtension"))
    }

    @Test("A choice written by hand with a name nobody knows reads as custom")
    func handWrittenUnknownIsCustom() throws {
        let written = Data(#"{"version":1,"defaultKind":{"kind":"wibble"}}"#.utf8)

        let read = try JSONDecoder().decode(Preferences.self, from: written)

        #expect(read.defaultKind == .custom(""))
    }
}
