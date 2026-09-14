import Testing

@testable import RightClickMenuCore

@Suite("Built in legend")
struct BuiltInLegendTests {

    @Test("Arrives with the five types that were asked for, in order", arguments: [
        ("core:markdown", "md"),
        ("core:json", "json"),
        ("core:shell", "sh"),
        ("core:javascript", "js"),
        ("core:python", "py"),
    ])
    func arrivesWithTheFive(id: String, ext: String) throws {
        let type = BuiltInLegend.load().type(withId: try FileTypeIdentifier(id))

        #expect(type?.fileExtension == ext)
    }

    @Test("Arrives with those five and nothing else")
    func arrivesWithNothingElse() {
        #expect(BuiltInLegend.load().types.count == 5)
    }

    @Test("Every type it arrives with belongs to the built in namespace")
    func allInBuiltInNamespace() {
        let namespaces = Set(BuiltInLegend.load().types.map(\.id.namespace))

        #expect(namespaces == [IdentifierConstants.builtInNamespace])
    }

    @Test("No type repeats another one's id", arguments: [
        BuiltInLegend.load(),
        BuiltInLegend.knownTypes(),
    ])
    func noRepeatedIds(legend: Legend) {
        #expect(Set(legend.types.map(\.id)).count == legend.types.count)
    }

    @Test("Every type has a name to show and an extension to write", arguments: [
        BuiltInLegend.load(),
        BuiltInLegend.knownTypes(),
    ])
    func everyTypeIsComplete(legend: Legend) {
        for type in legend.types {
            #expect(!type.displayName.isEmpty)
            #expect(!type.fileExtension.isEmpty)
            #expect(!type.defaultBaseName.isEmpty)
        }
    }

    @Test("Carries today's schema version")
    func carriesSchemaVersion() {
        #expect(BuiltInLegend.load().version == LegendConstants.schemaVersion)
    }

    @Test("The list to pick from offers plain text first, so it can be the default")
    func knownTypesOfferTextFirst() {
        let first = BuiltInLegend.knownTypes().types.first

        #expect(first?.fileExtension == DefaultsConstants.fallbackExtension)
    }

    @Test("The list to pick from is longer than what the app arrives with")
    func knownTypesIsLonger() {
        #expect(BuiltInLegend.knownTypes().types.count > BuiltInLegend.load().types.count)
    }

    @Test("Everything the app arrives with can also be picked from the list")
    func everyDefaultIsPickable() {
        let known = Set(BuiltInLegend.knownTypes().types.map(\.id))

        #expect(BuiltInLegend.load().types.allSatisfy { known.contains($0.id) })
    }
}
