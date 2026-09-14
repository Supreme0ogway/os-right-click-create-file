import SwiftUI

/// The app's one window.
///
/// It shows the file types, and the settings button swaps it for everything else,
/// with a way back. Layout only: which of the two is showing is the only thing it
/// holds, and that is where somebody looked, not what the app knows.
public struct MainWindowView: View {

    private let legend: LegendEditorViewModel
    private let scope: ScopePickerViewModel
    private let transfer: TransferViewModel
    private let version: String

    @State private var showsSettings = false

    /// Builds the window.
    ///
    /// - Parameters:
    ///   - legend: The model for the list of file types.
    ///   - scope: The model for where the menu appears.
    ///   - transfer: The model for moving file types in and out.
    ///   - version: Which version the app is.
    public init(
        legend: LegendEditorViewModel,
        scope: ScopePickerViewModel,
        transfer: TransferViewModel,
        version: String
    ) {
        self.legend = legend
        self.scope = scope
        self.transfer = transfer
        self.version = version
    }

    public var body: some View {
        content
            .frame(
                minWidth: WindowLayout.minimumWidth,
                minHeight: WindowLayout.minimumHeight
            )
    }

    @ViewBuilder
    private var content: some View {
        if showsSettings {
            SettingsView(
                scope: scope,
                transfer: transfer,
                version: version
            ) { showsSettings = false }
        }

        if !showsSettings {
            LegendEditorView(model: legend) { showsSettings = true }
        }
    }
}

/// Fixed sizes for the window.
enum WindowLayout {

    /// The narrowest the window may get.
    static let minimumWidth: CGFloat = 660

    /// The shortest the window may get.
    static let minimumHeight: CGFloat = 480
}
