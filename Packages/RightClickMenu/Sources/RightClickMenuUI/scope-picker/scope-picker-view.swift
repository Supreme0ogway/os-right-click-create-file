import SwiftUI

/// The panel that chooses where the right click menu appears.
///
/// Layout only. What each choice means, and what happens when the last folder goes,
/// is decided in the model this reads from.
public struct ScopePickerPanel: View {

    private let model: ScopePickerViewModel

    /// Builds the panel.
    ///
    /// - Parameter model: What it knows and can do.
    public init(model: ScopePickerViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FieldLayout.rowGap) {
            Picker(UIText.scopeTitle, selection: choiceBinding) {
                Text(UIText.everywhere).tag(true)
                Text(UIText.pickedFolders).tag(false)
            }
            .pickerStyle(.inline)
            .labelsHidden()

            if !model.isEverywhere {
                folders
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FieldLayout.formPadding)
    }

    private var choiceBinding: Binding<Bool> {
        Binding(
            get: { model.isEverywhere },
            set: { wantsEverywhere in
                wantsEverywhere ? model.useEverywhere() : model.usePickedFolders()
            }
        )
    }

    private var folders: some View {
        VStack(alignment: .leading, spacing: ScopeLayout.blockGap) {
            if !model.folderPaths.isEmpty {
                folderList
            }

            Button(UIText.addFolder, systemImage: EditorLayout.addIconName, action: pickFolder)

            Text(noteLine)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, model.folderPaths.isEmpty ? ScopeLayout.emptyGap : 0)
    }

    private var folderList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(model.folderPaths.enumerated()), id: \.element) { place, path in
                if place > 0 {
                    Divider()
                }

                FolderRow(path: path) { model.removeFolder(path) }
                    .padding(.vertical, ScopeLayout.rowPadding)
            }
        }
    }

    private var noteLine: String {
        model.showsNowhereWarning ? UIText.nowhereMessage : UIText.pickedNote
    }

    private func pickFolder() {
        guard let folder = FolderPanel.ask() else { return }
        model.addFolder(folder)
    }
}

/// Fixed spaces for the panel that chooses where the menu appears.
enum ScopeLayout {

    /// The space between the blocks of the panel.
    static let blockGap: CGFloat = 12

    /// The space above the add button while no folder has been chosen, so the button
    /// does not sit hard against the choice above it.
    static let emptyGap: CGFloat = 10

    /// The space above and below one folder in the list.
    static let rowPadding: CGFloat = 7
}

/// One folder in the list, with the way to drop it.
struct FolderRow: View {

    let path: String
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Text(path)
                .truncationMode(.middle)
                .lineLimit(1)
            Spacer()
            Button(UIText.remove, systemImage: EditorLayout.removeIconName, action: onRemove)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
        }
    }
}
