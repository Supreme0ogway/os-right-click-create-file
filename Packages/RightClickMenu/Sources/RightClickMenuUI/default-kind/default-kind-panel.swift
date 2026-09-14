import SwiftUI

/// The part of settings that chooses what the add screen starts on.
///
/// Choosing custom reveals a box for the extension to start from. Leaving that box
/// blank means the extension is typed every time, which is what somebody who adds a
/// different kind each time wants.
///
/// Layout only. Which kinds are offered and what is remembered are the model's job.
struct DefaultKindPanel: View {

    let model: DefaultKindViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: FieldLayout.rowGap) {
            VStack(alignment: .leading, spacing: FieldLayout.lineGap) {
                FieldLabel(UIText.defaultKindLabel)

                Picker(UIText.defaultKindLabel, selection: kindBinding) {
                    ForEach(model.choices) { choice in
                        Text(choice.displayName).tag(choice.fileExtension)
                    }
                    Text(UIText.addCustom).tag(AddTypeLayout.customTag)
                }
                .labelsHidden()
                .fixedSize()

                Text(UIText.defaultKindNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if model.isCustom {
                LabelledField(
                    label: UIText.defaultKindCustomExtension,
                    placeholder: AddTypeLayout.extensionHint,
                    hint: UIText.defaultKindCustomHint,
                    text: customBinding
                )
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FieldLayout.formPadding)
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

    private var customBinding: Binding<String> {
        Binding(
            get: { model.customExtension },
            set: { model.setCustomExtension($0) }
        )
    }
}
