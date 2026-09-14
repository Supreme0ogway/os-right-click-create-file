import Testing

@testable import RightClickMenuUI

@MainActor
@Suite("Add type view model")
struct AddTypeViewModelTests {

    private func makeModel() -> AddTypeViewModel {
        AddTypeViewModel(known: BuiltInLegend.knownTypes(), taken: [])
    }

    @Test("Offers the shipped list to pick from")
    func offersTheShippedList() {
        #expect(!makeModel().choices.isEmpty)
    }

    @Test("Starts on plain text, so there is always a sensible answer already")
    func startsOnPlainText() {
        let model = makeModel()

        #expect(model.pickedExtension == DefaultsConstants.fallbackExtension)
        #expect(!model.isCustom)
    }

    @Test("Is ready straight away, because the starting answer is a whole one")
    func readyStraightAway() {
        #expect(makeModel().isReady)
    }

    @Test("Picking from the list fills in the name to match")
    func pickingFillsInTheName() {
        let model = makeModel()

        model.pick("md")

        #expect(model.name.contains("Markdown"))
        #expect(model.pickedExtension == "md")
    }

    @Test("Choosing custom empties the extension so it has to be typed")
    func customEmptiesExtension() {
        let model = makeModel()

        model.useCustom()

        #expect(model.isCustom)
        #expect(model.customExtension.isEmpty)
        #expect(!model.isReady)
    }

    @Test("A custom type is ready once it has both a name and an extension")
    func customReadyWhenFilledIn() {
        let model = makeModel()
        model.useCustom()

        model.customExtension = "conf"
        model.name = "Config File"

        #expect(model.isReady)
    }

    @Test("A custom type with no name is not ready")
    func customNeedsAName() {
        let model = makeModel()
        model.useCustom()
        model.customExtension = "conf"

        model.name = "   "

        #expect(!model.isReady)
    }

    @Test("A custom type with no extension is not ready")
    func customNeedsAnExtension() {
        let model = makeModel()
        model.useCustom()
        model.name = "Config File"

        model.customExtension = "  "

        #expect(!model.isReady)
    }

    @Test("A blank file name is not ready, because every new file needs one")
    func needsAFileName() {
        let model = makeModel()

        model.baseName = " "

        #expect(!model.isReady)
    }

    @Test("Refuses an extension holding a dot rather than quietly fixing it")
    func refusesDotInExtension() {
        let model = makeModel()
        model.useCustom()
        model.name = "Config File"
        model.customExtension = ".conf"

        #expect(model.extensionProblem == .holdsDot)
        #expect(!model.isReady)
    }

    @Test("Refuses an extension holding a space")
    func refusesSpaceInExtension() {
        let model = makeModel()
        model.useCustom()
        model.name = "Config File"
        model.customExtension = "my conf"

        #expect(model.extensionProblem == .holdsSpace)
    }

    @Test("Takes blank space off the ends of every field it builds from")
    func trimsEveryField() {
        let model = makeModel()
        model.useCustom()
        model.customExtension = "  conf  "
        model.name = "  Config File  "
        model.baseName = "  settings  "

        let built = model.build()

        #expect(built?.fileExtension == "conf")
        #expect(built?.displayName == "Config File")
        #expect(built?.defaultBaseName == "settings")
    }

    @Test("Refuses a file name that would put the file somewhere else")
    func refusesPathInBaseName() {
        let model = makeModel()

        model.baseName = "../elsewhere"

        #expect(model.baseNameProblem == .holdsPathCharacter)
        #expect(!model.isReady)
    }

    @Test("Builds a type that belongs to the user, never to the app")
    func buildsAUserType() {
        let built = makeModel().build()

        #expect(built?.id.namespace.hasPrefix(IdentifierConstants.userNamespacePrefix) == true)
    }

    @Test("Builds what was picked")
    func buildsWhatWasPicked() {
        let model = makeModel()
        model.pick("py")
        model.baseName = "script"

        let built = model.build()

        #expect(built?.fileExtension == "py")
        #expect(built?.defaultBaseName == "script")
    }

    @Test("Builds nothing while it is not ready")
    func buildsNothingWhenNotReady() {
        let model = makeModel()
        model.useCustom()

        #expect(model.build() == nil)
    }

    @Test("Gives a type an id nothing else is using")
    func givesAFreeId() {
        let model = AddTypeViewModel(known: BuiltInLegend.knownTypes(), taken: [])
        let first = model.build()

        let second = AddTypeViewModel(
            known: BuiltInLegend.knownTypes(),
            taken: [first!.id]
        ).build()

        #expect(first?.id != second?.id)
    }

    @Test("Carries the template of the type that was picked")
    func carriesThePickedTemplate() {
        let model = makeModel()

        model.pick("sh")

        #expect(model.build()?.template.contains("zsh") == true)
    }
}
