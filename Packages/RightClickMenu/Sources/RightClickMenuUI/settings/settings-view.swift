import SwiftUI

/// The settings screen.
///
/// A list on the left and one panel on the right, opening on about. Layout only:
/// which part is showing is where somebody looked, not what the app knows.
public struct SettingsView: View {

    private let scope: ScopePickerViewModel
    private let transfer: TransferViewModel
    private let defaultKind: DefaultKindViewModel
    private let version: String
    private let onBack: () -> Void

    @State private var showing: SettingsSection = .opening

    /// Builds the screen.
    ///
    /// - Parameters:
    ///   - scope: The model for where the menu appears.
    ///   - transfer: The model for moving file types in and out.
    ///   - defaultKind: The model for what the add screen starts on.
    ///   - version: Which version the app is.
    ///   - onBack: What to do when the back button is pressed.
    public init(
        scope: ScopePickerViewModel,
        transfer: TransferViewModel,
        defaultKind: DefaultKindViewModel,
        version: String,
        onBack: @escaping () -> Void
    ) {
        self.scope = scope
        self.transfer = transfer
        self.defaultKind = defaultKind
        self.version = version
        self.onBack = onBack
    }

    public var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $showing) { section in
                Label(section.title, systemImage: section.iconName)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(
                min: EditorLayout.listMinimumWidth,
                ideal: EditorLayout.listIdealWidth
            )
        } detail: {
            panel
        }
        .navigationTitle(showing.title)
        .overlay(alignment: .bottom) { problemToast }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(UIText.back, systemImage: SettingsLayout.backIconName, action: onBack)
            }
        }
    }

    @ViewBuilder
    private var panel: some View {
        switch showing {
        case .about:
            AboutPanel(version: version, latest: Changelog.load().latest)
        case .appearsIn:
            ScopePickerPanel(model: scope)
        case .newType:
            DefaultKindPanel(model: defaultKind)
        case .importExport:
            TransferPanel(model: transfer)
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
