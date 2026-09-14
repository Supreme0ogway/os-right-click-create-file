import FinderSync
import RightClickMenuUI
import SwiftUI

/// What drops down from the menu bar icon.
///
/// Layout only. It shows whether the Finder extension is switched on, offers the way
/// to switch it on, and gives the only way to close an app that has no dock icon.
///
/// It also says when the menu is switched off by the settings rather than by a fault:
/// no folders chosen, or no file types left. Both are allowed, and both look exactly
/// like the app being broken unless somebody is told.
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

        if services.scope.value.watchesNothing {
            Button(AppText.appearsNowhere) { editor.show() }
            Divider()
        }

        if services.legend.value.isEmpty {
            Button(AppText.noTypes) { editor.show() }
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
