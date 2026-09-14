import Foundation
import Testing

@testable import RightClickMenuUI

@MainActor
@Suite("Default kind view model")
struct DefaultKindViewModelTests {

    private func makeStore(_ kind: DefaultKind = .known("txt")) -> RecordStore<Preferences> {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return RecordStore(
            fileURL: folder.appending(path: PreferencesConstants.fileName),
            fallback: Preferences.fallback.startingWith(kind)
        )
    }

    private func makeModel(_ kind: DefaultKind = .known("txt")) -> DefaultKindViewModel {
        DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: makeStore(kind))
    }

    @Test("Offers every kind the app knows")
    func offersEveryKnownKind() {
        #expect(makeModel().choices.count == BuiltInLegend.knownTypes().types.count)
    }

    @Test("Shows the kind that was chosen")
    func showsChosenKind() {
        #expect(makeModel(.known("md")).picked == .known("md"))
    }

    @Test("Shows custom when custom was chosen")
    func showsCustom() {
        #expect(makeModel(.custom("")).picked == .custom(""))
    }

    @Test("Choosing a kind is remembered")
    func choosingIsRemembered() {
        let store = makeStore()
        let model = DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: store)

        model.choose(.known("py"))

        #expect(model.picked == .known("py"))
        #expect(store.value.defaultKind == .known("py"))
    }

    @Test("Choosing custom is remembered")
    func choosingCustomIsRemembered() {
        let store = makeStore()
        let model = DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: store)

        model.useCustom()

        #expect(store.value.defaultKind == .custom(""))
    }

    @Test("Follows the store when something else changes it")
    func followsTheStore() throws {
        let store = makeStore()
        let model = DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: store)

        try store.save(store.value.startingWith(.known("json")))

        #expect(model.picked == .known("json"))
    }

    @Test("Custom can remember an extension to start from")
    func customRemembersAnExtension() {
        let store = makeStore(.custom(""))
        let model = DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: store)

        model.setCustomExtension("conf")

        #expect(model.customExtension == "conf")
        #expect(store.value.defaultKind == .custom("conf"))
    }

    @Test("A blank custom extension is allowed, meaning type it every time")
    func blankCustomIsAllowed() {
        let store = makeStore(.custom("conf"))
        let model = DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: store)

        model.setCustomExtension("")

        #expect(model.customExtension.isEmpty)
        #expect(store.value.defaultKind == .custom(""))
    }

    @Test("Space around a remembered extension is taken off")
    func trimsRememberedExtension() {
        let store = makeStore(.custom(""))
        let model = DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: store)

        model.setCustomExtension("  conf  ")

        #expect(model.customExtension == "conf")
    }

    @Test("Switching to custom keeps whatever was already remembered")
    func switchingKeepsRemembered() {
        let store = makeStore(.custom("conf"))
        let model = DefaultKindViewModel(known: BuiltInLegend.knownTypes(), store: store)

        model.useCustom()

        #expect(model.customExtension == "conf")
    }

    @Test("A known kind reports no custom extension")
    func knownHasNoCustomExtension() {
        let model = makeModel(.known("md"))

        #expect(!model.isCustom)
        #expect(model.pickedExtension == "md")
        #expect(model.customExtension.isEmpty)
    }

    @Test("Names every choice, so the list can be read")
    func namesEveryChoice() {
        let model = makeModel()

        for choice in model.choices {
            #expect(!choice.displayName.isEmpty)
        }
    }
}

@MainActor
@Suite("Add screen starting kind")
struct AddScreenStartingKindTests {

    private func makeStore(_ kind: DefaultKind) -> RecordStore<Preferences> {
        let folder = URL.temporaryDirectory
            .appending(path: "right-click-menu-tests/\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return RecordStore(
            fileURL: folder.appending(path: PreferencesConstants.fileName),
            fallback: Preferences.fallback.startingWith(kind)
        )
    }

    private func makeAdd(_ kind: DefaultKind) -> AddTypeViewModel {
        AddTypeViewModel(
            known: BuiltInLegend.knownTypes(),
            taken: [],
            preferences: makeStore(kind)
        )
    }

    @Test("Opens on the kind that was chosen in settings")
    func opensOnChosenKind() {
        let model = makeAdd(.known("py"))

        #expect(!model.isCustom)
        #expect(model.chosenExtension == "py")
        #expect(model.name.contains("Python"))
    }

    @Test("Opens on custom when custom was chosen in settings")
    func opensOnCustom() {
        let model = makeAdd(.custom(""))

        #expect(model.isCustom)
        #expect(model.nameProblem == .missing)
        #expect(model.customExtension.isEmpty)
    }

    @Test("Opens with the extension that custom remembered")
    func opensWithRememberedExtension() {
        let model = makeAdd(.custom("conf"))

        #expect(model.isCustom)
        #expect(model.chosenExtension == "conf")
        #expect(model.extensionProblem == nil)
    }

    @Test("Falls back to the first kind when the chosen one is gone")
    func fallsBackWhenKindIsGone() {
        let model = makeAdd(.known("no-such-extension"))

        #expect(!model.isCustom)
        #expect(model.chosenExtension == DefaultsConstants.fallbackExtension)
    }
}
