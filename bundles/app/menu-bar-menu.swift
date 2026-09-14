import FinderSync
import RightClickMenuUI
import SwiftUI

/// What drops down from the menu bar icon.
///
/// Layout only. It shows whether the Finder extension is switched on, offers the way
/// to switch it on, and gives the only way to close an app that has no dock icon.
struct MenuBarMenu: View {

    let services: AppServices
    let editor: EditorWindow

    @State private var loginItem = LoginItem()

    var body: some View {
        if !FIFinderSyncController.isExtensionEnabled {
            Button(AppText.extensionIsOff) {
                FIFinderSyncController.showExtensionManagementInterface()
            }
            Divider()
        }

        if !services.sharesWithExtension {
            Text(AppText.notSharing)
            Divider()
        }

        Button(AppText.editFileTypes) { editor.show() }

        Toggle(loginItemLabel, isOn: loginItemBinding)

        Divider()

        Button(AppText.quit) { NSApp.terminate(nil) }
    }

    private var loginItemLabel: String {
        loginItem.state.needsApproval ? UIText.loginWaiting : AppText.openAtLogin
    }

    private var loginItemBinding: Binding<Bool> {
        Binding(
            get: {
                loginItem.refresh()
                return loginItem.state.isChecked
            },
            set: { _ in loginItem.toggle() }
        )
    }
}
