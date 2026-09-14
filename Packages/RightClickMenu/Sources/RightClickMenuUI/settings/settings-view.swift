import SwiftUI

/// The settings screen.
///
/// Everything that is not the list of file types: where the menu appears, moving file
/// types in and out, and what the app is. Layout only.
public struct SettingsView: View {

    private let scope: ScopePickerViewModel
    private let transfer: TransferViewModel
    private let version: String
    private let onBack: () -> Void

    /// Builds the screen.
    ///
    /// - Parameters:
    ///   - scope: The model for where the menu appears.
    ///   - transfer: The model for moving file types in and out.
    ///   - version: Which version the app is.
    ///   - onBack: What to do when the back button is pressed.
    public init(
        scope: ScopePickerViewModel,
        transfer: TransferViewModel,
        version: String,
        onBack: @escaping () -> Void
    ) {
        self.scope = scope
        self.transfer = transfer
        self.version = version
        self.onBack = onBack
    }

    public var body: some View {
        Form {
            ScopePickerSection(model: scope)
            TransferSection(model: transfer)
            AboutSection(version: version, latest: Changelog.load().latest)
        }
        .formStyle(.grouped)
        .navigationTitle(UIText.settings)
        .toolbarBackground(Brand.band, for: .windowToolbar)
        .toolbarBackground(.visible, for: .windowToolbar)
        .overlay(alignment: .bottom) { problemToast }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(UIText.back, systemImage: SettingsLayout.backIconName, action: onBack)
            }
        }
    }

    @ViewBuilder
    private var problemToast: some View {
        if let problem = transfer.problem {
            Toast(message: problem)
                .task {
                    try? await Task.sleep(for: ToastLayout.staysFor)
                    transfer.clearProblem()
                }
        }
    }
}

/// Fixed symbols for the settings screen.
enum SettingsLayout {

    /// The symbol on the button that goes back to the list of file types.
    static let backIconName = "chevron.left"
}
