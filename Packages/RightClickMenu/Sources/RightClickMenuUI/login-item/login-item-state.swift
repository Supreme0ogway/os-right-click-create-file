import ServiceManagement

/// Whether the app opens when the mac starts, as the menu should show it.
///
/// The system has four answers and the menu has two, so the mapping is written down
/// here where it can be checked without touching the real setting.
///
/// - Note: Asking to open at login often leaves the setting waiting for the user to
///   allow it in System Settings rather than switched straight on. That still counts
///   as ticked, because the user asked for it. Treating it as unticked is what makes
///   a second click ask again instead of taking it off.

/// What the menu should show.
public enum LoginItemState: Equatable, Sendable {

    /// The app does not open at login.
    case off

    /// The app opens at login.
    case on

    /// The user asked for it and the system is waiting for them to allow it.
    case waitingForApproval

    /// What clicking the menu entry should do next.
    public enum NextAction: Equatable, Sendable {

        /// Ask for the app to open at login.
        case add

        /// Stop the app opening at login.
        case remove
    }

    /// Reads the system's answer.
    ///
    /// - Parameter status: What the system says about the login item.
    /// - Returns: What the menu should show.
    public static func from(_ status: SMAppService.Status) -> Self {
        switch status {
        case .enabled: .on
        case .requiresApproval: .waitingForApproval
        case .notRegistered, .notFound: .off
        @unknown default: .off
        }
    }

    /// Whether the menu entry shows a tick.
    public var isChecked: Bool { self != .off }

    /// What clicking the entry should do.
    public var nextAction: NextAction { isChecked ? .remove : .add }

    /// Whether to tell the user they still have to allow it in System Settings.
    public var needsApproval: Bool { self == .waitingForApproval }
}
