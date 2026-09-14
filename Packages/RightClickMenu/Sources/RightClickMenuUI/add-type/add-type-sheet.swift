import SwiftUI

/// The screen for adding a file type.
///
/// Deliberately short: a kind, a name, and the extension only when the kind is one the
/// app does not already know. Everything else about a type is changed afterwards on
/// the screen made for it, so nothing here has to be decided twice.
///
/// Layout only. What is offered and what counts as filled in are the model's job.
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
        VStack(alignment: .leading, spacing: AddTypeLayout.rowGap) {
            kindRow

            if model.isCustom {
                LabelledField(
                    label: UIText.fileExtension,
                    placeholder: AddTypeLayout.extensionHint,
                    hint: UIText.extensionHint,
                    problem: UIText.saying(model.extensionProblem),
                    text: $model.customExtension
                )
            }

            LabelledField(
                label: UIText.name,
                problem: UIText.saying(model.nameProblem),
                text: $model.name
            )

            buttons
        }
        .padding(AddTypeLayout.padding)
        .frame(width: AddTypeLayout.width)
    }

    private var kindRow: some View {
        HStack(spacing: AddTypeLayout.iconGap) {
            FileTypeIcon(fileExtension: model.chosenExtension)
                .frame(width: AddTypeLayout.iconSize, height: AddTypeLayout.iconSize)

            Picker(UIText.addKind, selection: kindBinding) {
                ForEach(model.choices) { choice in
                    Text(choice.displayName).tag(choice.fileExtension)
                }
                Text(UIText.addCustom).tag(AddTypeLayout.customTag)
            }
            .labelsHidden()
        }
    }

    private var buttons: some View {
        HStack {
            Button(UIText.addCancel, action: onCancel)
                .keyboardShortcut(.cancelAction)
            Spacer()
            Button(UIText.addConfirm, action: add)
                .keyboardShortcut(.defaultAction)
                .disabled(!model.isReady)
        }
        .padding(.top, AddTypeLayout.buttonsTopPadding)
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
    static let width: CGFloat = 360

    /// The space around everything on the screen.
    static let padding: CGFloat = 24

    /// The space between one row and the next.
    static let rowGap: CGFloat = 18

    /// The space between the icon and the dropdown beside it.
    static let iconGap: CGFloat = 12

    /// The extra space above the buttons at the bottom.
    static let buttonsTopPadding: CGFloat = 6

    /// How big the icon beside the dropdown is.
    static let iconSize: CGFloat = 34
}
