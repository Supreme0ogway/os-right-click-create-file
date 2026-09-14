/// The parts of settings, as the list on the left shows them.
///
/// About comes first and is what settings opens on, because it is the part somebody
/// lands on settings wanting to read rather than change.
public enum SettingsSection: String, CaseIterable, Identifiable, Sendable {

    /// What the app is, and what changed in it.
    case about

    /// Where the right click menu appears.
    case appearsIn

    /// What the add screen starts on.
    case newType

    /// Writing the file types out to a file and reading them back.
    case importExport

    /// The section settings opens on.
    public static let opening = Self.about

    /// What tells one section from another.
    public var id: String { rawValue }

    /// What the list on the left calls this section.
    public var title: String {
        switch self {
        case .about: UIText.aboutTitle
        case .appearsIn: UIText.scopeTitle
        case .newType: UIText.defaultKindTitle
        case .importExport: UIText.transferTitle
        }
    }

    /// The symbol shown beside this section in the list.
    public var iconName: String {
        switch self {
        case .about: "info.circle"
        case .appearsIn: "folder"
        case .newType: "plus.rectangle.on.folder"
        case .importExport: "arrow.up.arrow.down"
        }
    }
}
