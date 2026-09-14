import SwiftUI

/// The part of settings that says what the app is and what changed.
///
/// Shows only the newest release. Somebody looking here wants to know what just
/// changed, not the whole history.
struct AboutSection: View {

    let version: String
    let latest: Release?

    var body: some View {
        Section {
            LabeledContent(UIText.aboutTitle) {
                Text(UIText.version(version))
                    .foregroundStyle(.secondary)
            }

            if let latest {
                VStack(alignment: .leading, spacing: AboutLayout.noteGap) {
                    Text(UIText.whatsNew)
                        .font(.headline)
                    ForEach(latest.notes, id: \.self) { note in
                        Label(note, systemImage: AboutLayout.noteIconName)
                            .font(.callout)
                            .labelStyle(.titleAndIcon)
                    }
                }
                .padding(.vertical, AboutLayout.blockPadding)
            }
        } header: {
            Text(UIText.aboutTitle)
        }
    }
}

/// Fixed sizes and symbols for the about part of settings.
enum AboutLayout {

    /// The symbol beside each line of what changed.
    static let noteIconName = "circle.fill"

    /// The space between the lines of what changed.
    static let noteGap: CGFloat = 8

    /// The space above and below the block of notes.
    static let blockPadding: CGFloat = 6
}
