import Observation

/// What the add screen knows and can do.
///
/// A type is either one of the kinds the app already knows, picked from a list, or a
/// custom one whose extension is typed in. Either way it is not finished until it has
/// a name, an extension and something to call the files it makes.
///
/// Imports nothing to do with drawing, so every rule below is covered by the ordinary
/// test run.
@MainActor
@Observable
public final class AddTypeViewModel {

    /// The kinds of file the list offers to pick from.
    public let choices: [FileType]

    /// The extension picked from the list. Ignored while a custom one is being typed.
    public private(set) var pickedExtension: String

    /// Whether an extension is being typed in rather than picked.
    public private(set) var isCustom = false

    /// The extension being typed in. Only used while ``isCustom`` is true.
    public var customExtension = ""

    /// What the entry will say in the right click menu.
    public var name: String

    /// What a new file of this type will be called.
    public var baseName: String

    /// What a new file of this type will start with.
    public var template: String

    private let taken: Set<FileTypeIdentifier>

    /// Builds the add screen's model, already filled in with a sensible answer.
    ///
    /// - Parameters:
    ///   - known: The kinds of file the app already knows about.
    ///   - taken: The ids already in use, so a new type never clashes.
    public init(known: Legend, taken: Set<FileTypeIdentifier>) {
        let first = known.types.first

        choices = known.types
        self.taken = taken
        pickedExtension = first?.fileExtension ?? DefaultsConstants.fallbackExtension
        name = first?.displayName ?? ""
        baseName = first?.defaultBaseName ?? LegendConstants.fallbackBaseName
        template = first?.template ?? ""
    }

    /// The extension the new type will really get, with nothing blank around it.
    public var chosenExtension: String {
        FileTypeCheck.tidied(isCustom ? customExtension : pickedExtension)
    }

    /// What is wrong with the name, if anything.
    public var nameProblem: FileTypeProblem? { FileTypeCheck.nameProblem(name) }

    /// What is wrong with the extension, if anything.
    public var extensionProblem: FileTypeProblem? {
        FileTypeCheck.extensionProblem(isCustom ? customExtension : pickedExtension)
    }

    /// What is wrong with what new files are called, if anything.
    public var baseNameProblem: FileTypeProblem? { FileTypeCheck.baseNameProblem(baseName) }

    /// Whether every part has been filled in and is allowed.
    public var isReady: Bool {
        nameProblem == nil && extensionProblem == nil && baseNameProblem == nil
    }

    /// Picks one of the kinds the app knows, filling the rest in to match.
    ///
    /// - Parameter fileExtension: The extension of the kind that was picked.
    public func pick(_ fileExtension: String) {
        guard let choice = choices.first(where: { $0.fileExtension == fileExtension }) else {
            return
        }
        isCustom = false
        pickedExtension = choice.fileExtension
        name = choice.displayName
        baseName = choice.defaultBaseName
        template = choice.template
    }

    /// Switches to typing an extension in rather than picking one.
    ///
    /// The extension is emptied on purpose, so nothing is added by accident under a
    /// kind that was only ever the starting answer.
    public func useCustom() {
        isCustom = true
        customExtension = ""
        template = ""
    }

    /// Builds the type, when there is enough to build one.
    ///
    /// - Returns: The new type, or `nil` while something is still missing.
    public func build() -> FileType? {
        guard isReady, let id = freeIdentifier() else { return nil }
        return FileType(
            id: id,
            displayName: FileTypeCheck.tidied(name),
            fileExtension: chosenExtension,
            defaultBaseName: FileTypeCheck.tidied(baseName),
            template: template
        )
    }

    private func freeIdentifier() -> FileTypeIdentifier? {
        let namespace = IdentifierConstants.userNamespacePrefix + ".new"
        let stem = chosenExtension.lowercased()

        for attempt in 1...LegendConstants.maximumTypeCount {
            let suffix = attempt == 1 ? "" : "-\(attempt)"
            guard let candidate = try? FileTypeIdentifier("\(namespace):\(stem)\(suffix)") else {
                return nil
            }
            guard taken.contains(candidate) else { return candidate }
        }
        return nil
    }
}
