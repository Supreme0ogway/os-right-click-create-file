import SwiftUI

/// The screen for adding a file type.
///
/// Layout only. Which kinds are offered, what counts as filled in, and what the new
/// type ends up being are all decided in the model.
struct AddTypeSheet: View {

    @State private var model: AddTypeViewModel

    private let onAdd: (FileType) -> Void
    private let onCancel: () -> Void

    init(
        model: AddTypeViewModel,
        onAdd: @escaping (FileType) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._model = State(initialValue: model)
        self.onAdd = onAdd
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: FieldLayout.rowGap) {
                    icon
                    kindPicker
                    customExtensionField
                    nameField
                    baseNameField
                }
                .padding(FieldLayout.formPadding)
            }

            buttons
        }
        .frame(width: AddTypeLayout.width, height: AddTypeLayout.height)
    }

    private var icon: some View {
        VStack(alignment: .leading, spacing: IconLayout.gap) {
            FileTypeIcon(fileExtension: model.chosenExtension)
            Text(UIText.iconNote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var kindPicker: some View {
        VStack(alignment: .leading, spacing: FieldLayout.lineGap) {
            FieldLabel(UIText.addKind)
            Picker(UIText.addKind, selection: kindBinding) {
                ForEach(model.choices) { choice in
                    Text(choice.displayName).tag(choice.fileExtension)
                }
                Text(UIText.addCustom).tag(AddTypeLayout.customTag)
            }
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var customExtensionField: some View {
        if model.isCustom {
            LabelledField(
                label: UIText.fileExtension,
                placeholder: AddTypeLayout.extensionHint,
                hint: UIText.extensionHint,
                problem: UIText.saying(model.extensionProblem),
                text: $model.customExtension
            )
        }
    }

    private var nameField: some View {
        LabelledField(
            label: UIText.name,
            hint: UIText.nameHint,
            problem: UIText.saying(model.nameProblem),
            text: $model.name
        )
    }

    private var baseNameField: some View {
        LabelledField(
            label: UIText.baseName,
            hint: UIText.baseNameHint,
            problem: UIText.saying(model.baseNameProblem),
            text: $model.baseName
        )
    }

    private var buttons: some View {
        HStack {
            Spacer()
            Button(UIText.addCancel, action: onCancel)
                .keyboardShortcut(.cancelAction)
            Button(UIText.addConfirm, action: add)
                .keyboardShortcut(.defaultAction)
                .disabled(!model.isReady)
        }
        .padding(AddTypeLayout.buttonPadding)
        .background(.bar)
    }

    private var kindBinding: Binding<String> {
        Binding(
            get: { model.isCustom ? AddTypeLayout.customTag : model.pickedExtension },
            set: { picked in
                guard picked != AddTypeLayout.customTag else {
                    model.useCustom()
                    return
                }
                model.pick(picked)
            }
        )
    }

    private func add() {
        guard let type = model.build() else { return }
        onAdd(type)
    }
}

/// Fixed sizes and names for the add screen.
enum AddTypeLayout {

    /// The value the dropdown uses for the custom entry. Never a real extension.
    static let customTag = "  custom  "

    /// What the extension box shows while it is empty.
    static let extensionHint = "conf"

    /// How wide the screen is.
    static let width: CGFloat = 460

    /// How tall the screen is.
    static let height: CGFloat = 520

    /// The space around the buttons at the bottom.
    static let buttonPadding: CGFloat = 14
}
