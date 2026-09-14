import SwiftUI

/// The part of settings that chooses where the right click menu appears.
///
/// Layout only. What each choice means, and what happens when the last folder goes,
/// is decided in the model this reads from.
public struct ScopePickerSection: View {

    private let model: ScopePickerViewModel

    /// Builds the section.
    ///
    /// - Parameter model: What it knows and can do.
    public init(model: ScopePickerViewModel) {
        self.model = model
    }

    public var body: some View {
        Section {
            Picker(UIText.scopeTitle, selection: choiceBinding) {
                Text(UIText.everywhere).tag(true)
                Text(UIText.pickedFolders).tag(false)
            }
            .pickerStyle(.inline)
            .labelsHidden()

            if !model.isEverywhere {
                folderRows
            }
        } header: {
            Text(UIText.scopeTitle)
        } footer: {
            Text(UIText.pickedNote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var choiceBinding: Binding<Bool> {
        Binding(
            get: { model.isEverywhere },
            set: { wantsEverywhere in
                wantsEverywhere ? model.useEverywhere() : model.usePickedFolders()
            }
        )
    }

    @ViewBuilder
    private var folderRows: some View {
        ForEach(model.folderPaths, id: \.self) { path in
            FolderRow(path: path) { model.removeFolder(path) }
        }

        if model.showsNowhereWarning {
            EmptyState(
                title: UIText.nowhereTitle,
                message: UIText.nowhereMessage,
                iconName: EditorLayout.emptyIconName
            )
        }

        Button(UIText.addFolder, systemImage: EditorLayout.addIconName, action: pickFolder)
    }

    private func pickFolder() {
        guard let folder = FolderPanel.ask() else { return }
        model.addFolder(folder)
    }
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
