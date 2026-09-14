import Testing

@testable import RightClickMenuShared

@Suite("Trimmed text")
struct TrimmedTests {

    @Test("Leaves text with nothing around it alone")
    func leavesCleanTextAlone() {
        #expect("Untitled".trimmed == "Untitled")
    }

    @Test("Takes space off both ends")
    func takesSpaceOffBothEnds() {
        #expect("  Untitled  ".trimmed == "Untitled")
    }

    @Test("Takes tabs and newlines off too")
    func takesTabsAndNewlinesOff() {
        #expect("\n\tUntitled\t\n".trimmed == "Untitled")
    }

    @Test("Keeps the space inside, because that is part of the name")
    func keepsInnerSpace() {
        #expect("  My Invoice  ".trimmed == "My Invoice")
    }

    @Test("Text that is nothing but space comes back empty")
    func allSpaceComesBackEmpty() {
        #expect("   \n\t ".trimmed.isEmpty)
    }

    @Test("Empty text stays empty")
    func emptyStaysEmpty() {
        #expect("".trimmed.isEmpty)
    }
}
