import Foundation

/// Every word the screens show a person.
///
/// Looked up by key so the wording can change without touching the screens, and so a
/// control never holds words of its own.
public enum UIText {

    /// The name a newly added type starts with.
    public static let newTypeName = String(localized: "editor.new-type-name", bundle: .module)

    /// The extension a newly added type starts with.
    public static let newTypeExtension = String(
        localized: "editor.new-type-extension",
        bundle: .module
    )

    /// Shown in place of the list when every type has been removed.
    public static let emptyTitle = String(localized: "editor.empty-title", bundle: .module)

    /// Explains that an empty list is allowed, and what it does.
    public static let emptyMessage = String(localized: "editor.empty-message", bundle: .module)

    /// Adds a file type.
    public static let add = String(localized: "editor.add", bundle: .module)

    /// Removes the file type on this row.
    public static let remove = String(localized: "editor.remove", bundle: .module)

    /// The name shown in the right click menu.
    public static let name = String(localized: "editor.name", bundle: .module)

    /// The file extension, such as txt.
    public static let fileExtension = String(localized: "editor.extension", bundle: .module)

    /// What a new file is called before its extension.
    public static let baseName = String(localized: "editor.base-name", bundle: .module)

    /// The text every new file of this type starts with.
    public static let template = String(localized: "editor.template", bundle: .module)

    /// The editor window's title.
    public static let title = String(localized: "editor.title", bundle: .module)

    /// The tab holding the list of file types.
    public static let tabTypes = String(localized: "scope.tab-types", bundle: .module)

    /// The tab holding the choice of where the menu appears.
    public static let tabWhere = String(localized: "scope.tab-where", bundle: .module)

    /// Shows the menu in every folder.
    public static let everywhere = String(localized: "scope.everywhere", bundle: .module)

    /// Shows the menu only in folders the user picks.
    public static let pickedFolders = String(localized: "scope.picked-folders", bundle: .module)

    /// Explains that a picked folder also covers what is inside it.
    public static let pickedNote = String(localized: "scope.picked-note", bundle: .module)

    /// Opens the panel for picking a folder.
    public static let addFolder = String(localized: "scope.add-folder", bundle: .module)

    /// The title of the panel for picking a folder.
    public static let chooseFolder = String(localized: "scope.choose-folder", bundle: .module)

    /// Confirms the picked folder.
    public static let choose = String(localized: "scope.choose", bundle: .module)

    /// Shown when folders were chosen and then all removed.
    public static let nowhereTitle = String(localized: "scope.nowhere-title", bundle: .module)

    /// Explains that the menu now appears nowhere.
    public static let nowhereMessage = String(localized: "scope.nowhere-message", bundle: .module)

    /// Shown beside opening at login while the user still has to allow it.
    public static let loginWaiting = String(localized: "login.waiting", bundle: .module)

    /// Goes back from the settings screen to the list of file types.
    public static let back = String(localized: "window.back", bundle: .module)

    /// Opens the settings screen.
    public static let settings = String(localized: "window.settings", bundle: .module)

    /// Adds a file type, shown as a plus in the toolbar.
    public static let addType = String(localized: "window.add-type", bundle: .module)

    /// Shown on the right when no file type has been picked yet.
    public static let nothingPickedTitle = String(
        localized: "editor.nothing-picked-title",
        bundle: .module
    )

    /// Tells the user to pick a file type to change it.
    public static let nothingPickedMessage = String(
        localized: "editor.nothing-picked-message",
        bundle: .module
    )

    /// Shown when a file of file types cannot be read.
    public static let fileIsDamaged = String(
        localized: "transfer.file-is-damaged",
        bundle: .module
    )

    /// Heading of the part of settings that moves file types in and out.
    public static let transferTitle = String(localized: "transfer.title", bundle: .module)

    /// Writes every file type out to a file.
    public static let export = String(localized: "transfer.export", bundle: .module)

    /// Reads file types back in from a file.
    public static let importTypes = String(localized: "transfer.import", bundle: .module)

    /// Explains what exporting and importing do.
    public static let transferNote = String(localized: "transfer.note", bundle: .module)

    /// Title of the panel for choosing where to write the file types.
    public static let chooseDestination = String(
        localized: "transfer.choose-destination",
        bundle: .module
    )

    /// Title of the panel for choosing a file of file types to read.
    public static let chooseSource = String(localized: "transfer.choose-source", bundle: .module)

    /// Heading of the part of settings saying what the app is.
    public static let aboutTitle = String(localized: "about.title", bundle: .module)

    /// Heading above the list of what changed in the newest release.
    public static let whatsNew = String(localized: "about.whats-new", bundle: .module)

    /// Heading of the part of settings choosing where the menu appears.
    public static let scopeTitle = String(localized: "scope.title", bundle: .module)

    /// Title of the screen for adding a file type.
    public static let addTitle = String(localized: "add.title", bundle: .module)

    /// Label for the dropdown of file kinds the app already knows.
    public static let addKind = String(localized: "add.kind", bundle: .module)

    /// The entry in the dropdown that lets an extension be typed in.
    public static let addCustom = String(localized: "add.custom", bundle: .module)

    /// Adds the file type and closes the screen.
    public static let addConfirm = String(localized: "add.confirm", bundle: .module)

    /// Closes the add screen without adding anything.
    public static let addCancel = String(localized: "add.cancel", bundle: .module)

    /// Shown when a search matched none of the file types.
    public static let noMatchesTitle = String(localized: "editor.no-matches-title", bundle: .module)

    /// Tells the user their search matched nothing.
    public static let noMatchesMessage = String(
        localized: "editor.no-matches-message",
        bundle: .module
    )

    /// The search box above the list of file types.
    public static let search = String(localized: "editor.search", bundle: .module)

    /// Says which version the app is.
    ///
    /// - Parameter version: The version, such as `0.1`.
    /// - Returns: The sentence to show.
    public static func version(_ version: String) -> String {
        String(format: String(localized: "about.version", bundle: .module), version)
    }

    /// A few words under the icon saying it follows the extension.
    public static let iconNote = String(localized: "editor.icon-note", bundle: .module)

    /// A few words under the extension box saying what is allowed.
    public static let extensionHint = String(localized: "editor.extension-hint", bundle: .module)

    /// A few words under the name box.
    public static let nameHint = String(localized: "editor.name-hint", bundle: .module)

    /// A few words under the file name box.
    public static let baseNameHint = String(localized: "editor.base-name-hint", bundle: .module)

    /// What every new file of this type starts with.
    public static let contents = String(localized: "editor.contents", bundle: .module)

    /// A few words under the contents editor.
    public static let contentsHint = String(localized: "editor.contents-hint", bundle: .module)

    /// Says what is wrong with something somebody typed.
    ///
    /// - Parameter problem: What the check found, or `nil` when nothing is wrong.
    /// - Returns: The sentence to show, or `nil` when there is nothing to say.
    public static func saying(_ problem: FileTypeProblem?) -> String? {
        switch problem {
        case .none: nil
        case .missing: String(localized: "problem.missing", bundle: .module)
        case .holdsDot: String(localized: "problem.holds-dot", bundle: .module)
        case .holdsSpace: String(localized: "problem.holds-space", bundle: .module)
        case .holdsPathCharacter:
            String(localized: "problem.holds-path-character", bundle: .module)
        }
    }
}
