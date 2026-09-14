import SwiftUI

/// The part of settings that writes file types out and reads them back.
///
/// Layout only. Reading a file and saying when one cannot be read are the model's job.
struct TransferSection: View {

    let model: TransferViewModel

    var body: some View {
        Section {
            HStack {
                Button(UIText.export, systemImage: TransferLayout.exportIconName, action: export)
                Button(
                    UIText.importTypes,
                    systemImage: TransferLayout.importIconName,
                    action: bringIn
                )
                Spacer()
            }
        } header: {
            Text(UIText.transferTitle)
        } footer: {
            Text(UIText.transferNote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func export() {
        guard let destination = FilePanel.askWhereToSave(named: model.suggestedFileName) else {
            return
        }
        model.export(to: destination)
    }

    private func bringIn() {
        guard let source = FilePanel.askForJSONFile() else { return }
        model.importFrom(source)
    }
}

/// Fixed symbols for moving file types in and out.
enum TransferLayout {

    /// The symbol on the button that writes the file types out.
    static let exportIconName = "square.and.arrow.up"

    /// The symbol on the button that reads file types in.
    static let importIconName = "square.and.arrow.down"
}
