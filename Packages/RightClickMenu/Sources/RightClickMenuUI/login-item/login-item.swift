import Observation
import ServiceManagement

/// Turning opening at login on and off.
///
/// The answer is always read back from the system rather than remembered, because the
/// user can change it in System Settings without this app ever being told.
@MainActor
@Observable
public final class LoginItem {

    /// What the menu should show right now.
    public private(set) var state: LoginItemState = .off

    /// The last thing the system refused, if anything.
    public private(set) var problem: String?

    /// Builds the controller and reads the current setting.
    public init() {
        refresh()
    }

    /// Reads the setting again, in case it was changed elsewhere.
    public func refresh() {
        state = LoginItemState.from(SMAppService.mainApp.status)
    }

    /// Turns opening at login on when it is off, and off when it is on.
    public func toggle() {
        do {
            try apply(state.nextAction)
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
        refresh()
    }

    private func apply(_ action: LoginItemState.NextAction) throws {
        guard action == .add else {
            try SMAppService.mainApp.unregister()
            return
        }
        try SMAppService.mainApp.register()
    }
}
