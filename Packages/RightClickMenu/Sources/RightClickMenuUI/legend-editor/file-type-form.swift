import SwiftUI

/// The rows for editing one file type.
///
/// Layout only. What counts as a usable name or extension is decided in the checks the
/// whole app shares, and the one true copy of the type is kept by the model.
///
/// Every box is tidied before it is saved, so nothing is ever stored with blank space
/// hanging off either end.
struct FileTypeForm: View {

    let type: FileType
    let model: LegendEditorViewModel

    @State private var displayName = ""
    @State private var fileExtension = ""
    @State private var baseName = ""
    @State private var template = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FieldLayout.rowGap) {
                icon

                LabelledField(
                    label: UIText.name,
                    hint: UIText.nameHint,
                    problem: UIText.saying(FileTypeCheck.nameProblem(displayName)),
                    text: $displayName
                )

                LabelledField(
                    label: UIText.fileExtension,
                    hint: UIText.extensionHint,
                    problem: UIText.saying(FileTypeCheck.extensionProblem(fileExtension)),
                    text: $fileExtension
                )

                LabelledField(
                    label: UIText.baseName,
                    hint: UIText.baseNameHint,
                    problem: UIText.saying(FileTypeCheck.baseNameProblem(baseName)),
                    text: $baseName
                )

                contentsEditor
            }
            .padding(FieldLayout.formPadding)
        }
        .overlay(alignment: .bottomTrailing) { removeBubble }
        .onAppear(perform: fillFromType)
        .onChange(of: displayName) { _, _ in save() }
        .onChange(of: fileExtension) { _, _ in save() }
        .onChange(of: baseName) { _, _ in save() }
        .onChange(of: template) { _, _ in save() }
    }

    private var icon: some View {
        VStack(alignment: .leading, spacing: IconLayout.gap) {
            FileTypeIcon(fileExtension: fileExtension)
            Text(UIText.iconNote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var contentsEditor: some View {
        VStack(alignment: .leading, spacing: FieldLayout.lineGap) {
            FieldLabel(UIText.contents)
            CodeEditor(text: $template, fileExtension: fileExtension)
                .frame(maxWidth: .infinity)
                .frame(height: CodeEditorLayout.height)
                .clipped()
            Text(UIText.contentsHint)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var removeBubble: some View {
        Button {
            model.askToRemove(type.id)
        } label: {
            Image(systemName: EditorLayout.removeIconName)
                .font(.system(size: EditorLayout.bubbleIconSize, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: EditorLayout.bubbleSize, height: EditorLayout.bubbleSize)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.separator))
                .shadow(radius: EditorLayout.bubbleShadow, y: EditorLayout.bubbleShadowDrop)
        }
        .buttonStyle(.plain)
        .help(UIText.remove)
        .padding(EditorLayout.bubblePadding)
    }

    private func fillFromType() {
        displayName = type.displayName
        fileExtension = type.fileExtension
        baseName = type.defaultBaseName
        template = type.template
    }

    private func save() {
        let hasProblem = FileTypeCheck.nameProblem(displayName) != nil
            || FileTypeCheck.extensionProblem(fileExtension) != nil
            || FileTypeCheck.baseNameProblem(baseName) != nil
        guard !hasProblem else { return }

        model.updateType(
            FileType(
                id: type.id,
                displayName: FileTypeCheck.tidied(displayName),
                fileExtension: FileTypeCheck.tidied(fileExtension),
                defaultBaseName: FileTypeCheck.tidied(baseName),
                template: template
            )
        )
    }
}
