import ServiceManagement
import Testing

@testable import RightClickMenuUI

@Suite("Login item state")
struct LoginItemStateTests {

    @Test("Enabled shows a tick")
    func enabledShowsTick() {
        #expect(LoginItemState.from(.enabled) == .on)
        #expect(LoginItemState.from(.enabled).isChecked)
    }

    @Test("Waiting for the user to allow it still shows a tick, because they asked for it")
    func waitingShowsTick() {
        #expect(LoginItemState.from(.requiresApproval) == .waitingForApproval)
        #expect(LoginItemState.from(.requiresApproval).isChecked)
    }

    @Test("Not registered shows no tick")
    func notRegisteredShowsNoTick() {
        #expect(LoginItemState.from(.notRegistered) == .off)
        #expect(!LoginItemState.from(.notRegistered).isChecked)
    }

    @Test("Not found shows no tick")
    func notFoundShowsNoTick() {
        #expect(LoginItemState.from(.notFound) == .off)
        #expect(!LoginItemState.from(.notFound).isChecked)
    }

    @Test("A ticked state is taken off, not put on again")
    func tickedStateTurnsOff() {
        #expect(LoginItemState.on.nextAction == .remove)
        #expect(LoginItemState.waitingForApproval.nextAction == .remove)
    }

    @Test("An unticked state is put on")
    func untickedStateTurnsOn() {
        #expect(LoginItemState.off.nextAction == .add)
    }

    @Test("Only the waiting state says the user still has to allow it")
    func onlyWaitingNeedsApproval() {
        #expect(LoginItemState.waitingForApproval.needsApproval)
        #expect(!LoginItemState.on.needsApproval)
        #expect(!LoginItemState.off.needsApproval)
    }
}
