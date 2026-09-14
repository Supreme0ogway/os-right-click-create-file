import Testing

@testable import RightClickMenuCore

@Suite("Menu plan")
struct MenuPlanTests {

    private func makeType(_ name: String, id: String) throws -> FileType {
        FileType(
            id: try FileTypeIdentifier(id),
            displayName: name,
            fileExtension: "txt",
            defaultBaseName: "Untitled",
            template: ""
        )
    }

    @Test("An empty legend plans nothing at all, so the menu looks untouched")
    func emptyLegendPlansNothing() {
        #expect(MenuPlan.entries(for: Legend.empty).isEmpty)
    }

    @Test("Plans one entry for each type, in the legend's order")
    func plansOneEntryPerType() throws {
        let legend = Legend(types: [
            try makeType("Markdown", id: "core:markdown"),
            try makeType("Text File", id: "core:plain-text"),
        ])

        let entries = MenuPlan.entries(for: legend)

        #expect(entries.count == 2)
        #expect(entries.map(\.typeId.text) == ["core:markdown", "core:plain-text"])
    }

    @Test("Names an entry after the type it makes")
    func namesEntryAfterType() throws {
        let legend = Legend(types: [try makeType("Text File", id: "core:plain-text")])

        let entries = MenuPlan.entries(for: legend)

        #expect(entries.first?.title.contains("Text File") == true)
    }

    @Test("Numbers the entries from zero, so a click can find its way back")
    func numbersEntriesFromZero() throws {
        let legend = Legend(types: [
            try makeType("Markdown", id: "core:markdown"),
            try makeType("Text File", id: "core:plain-text"),
        ])

        #expect(MenuPlan.entries(for: legend).map(\.place) == [0, 1])
    }

    @Test("Finds the type a click came from by its number")
    func findsTypeByNumber() throws {
        let legend = Legend(types: [
            try makeType("Markdown", id: "core:markdown"),
            try makeType("Text File", id: "core:plain-text"),
        ])

        #expect(MenuPlan.entry(at: 1, in: legend)?.typeId.text == "core:plain-text")
    }

    @Test("Finds nothing when the list shrank between the menu opening and the click")
    func findsNothingWhenListShrank() throws {
        let legend = Legend(types: [try makeType("Markdown", id: "core:markdown")])

        #expect(MenuPlan.entry(at: 4, in: legend) == nil)
    }

    @Test("Finds nothing for a number below zero")
    func findsNothingBelowZero() throws {
        let legend = Legend(types: [try makeType("Markdown", id: "core:markdown")])

        #expect(MenuPlan.entry(at: -1, in: legend) == nil)
    }

    @Test("Finds nothing at all in an empty legend")
    func findsNothingWhenEmpty() {
        #expect(MenuPlan.entry(at: 0, in: Legend.empty) == nil)
    }

    @Test("Says a menu with no entries should not be shown at all")
    func saysNothingToShow() {
        #expect(!MenuPlan.hasAnythingToShow(Legend.empty))
    }

    @Test("Says a menu with entries should be shown")
    func saysSomethingToShow() throws {
        let legend = Legend(types: [try makeType("Text File", id: "core:plain-text")])

        #expect(MenuPlan.hasAnythingToShow(legend))
    }
}

@Suite("Menu plan parent")
struct MenuPlanParentTests {

    @Test("The one entry has something to say")
    func parentHasATitle() {
        #expect(!MenuPlan.parentTitle.isEmpty)
    }

    @Test("The one entry is not named after any single type")
    func parentIsNotAType() throws {
        let legend = Legend(types: [
            FileType(
                id: try FileTypeIdentifier("core:markdown"),
                displayName: "Markdown File",
                fileExtension: "md",
                defaultBaseName: "Untitled",
                template: ""
            )
        ])

        let titles = MenuPlan.entries(for: legend).map(\.title)

        #expect(!titles.contains(MenuPlan.parentTitle))
    }
}
