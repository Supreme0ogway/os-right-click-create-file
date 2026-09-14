import Testing

@testable import RightClickMenuShared

@Suite("Bundle constants")
struct BundleConstantsTests {

    @Test("The extension's name sits under the app's, which the system insists on")
    func extensionSitsUnderApp() {
        #expect(BundleConstants.extensionIdentifier.hasPrefix(BundleConstants.appIdentifier + "."))
    }

    @Test("The shared folder is named after the team that signed the bundle")
    func groupStartsWithTheTeam() {
        let group = BundleConstants.appGroupIdentifier(team: "ABCDE12345")

        #expect(group == "ABCDE12345.group.com.willlattus.right-click-menu")
    }

    @Test("A different team gives a different folder, so two builds never share one")
    func differentTeamsDoNotShare() {
        let mine = BundleConstants.appGroupIdentifier(team: "ABCDE12345")
        let theirs = BundleConstants.appGroupIdentifier(team: "ZYXWV98765")

        #expect(mine != theirs)
    }
}
