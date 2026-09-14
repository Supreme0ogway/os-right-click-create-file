import Testing

@testable import RightClickMenuUI

@MainActor
@Suite("Settings section")
struct SettingsSectionTests {

    @Test("Settings opens on about")
    func opensOnAbout() {
        #expect(SettingsSection.opening == .about)
    }

    @Test("About is first in the list, where it is opened from")
    func aboutIsFirst() {
        #expect(SettingsSection.allCases.first == .about)
    }

    @Test("Every section has something to call it and a symbol to show")
    func everySectionIsShowable() {
        for section in SettingsSection.allCases {
            #expect(!section.title.isEmpty)
            #expect(!section.iconName.isEmpty)
        }
    }

    @Test("No two sections share a name")
    func noSharedNames() {
        let titles = Set(SettingsSection.allCases.map(\.title))

        #expect(titles.count == SettingsSection.allCases.count)
    }
}
