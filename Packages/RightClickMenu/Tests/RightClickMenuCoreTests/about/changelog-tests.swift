import Testing

@testable import RightClickMenuCore

@Suite("Changelog")
struct ChangelogTests {

    @Test("Ships at least one release, so the about screen is never blank")
    func shipsARelease() {
        #expect(!Changelog.load().releases.isEmpty)
    }

    @Test("The newest release is the one shown")
    func newestIsShown() {
        let changelog = Changelog.load()

        #expect(changelog.latest == changelog.releases.first)
    }

    @Test("Every release says what it changed")
    func everyReleaseHasNotes() {
        for release in Changelog.load().releases {
            #expect(!release.notes.isEmpty)
            #expect(!release.version.isEmpty)
        }
    }

    @Test("An empty changelog has no newest release rather than failing")
    func emptyHasNoLatest() {
        #expect(Changelog(version: 1, releases: []).latest == nil)
    }
}
