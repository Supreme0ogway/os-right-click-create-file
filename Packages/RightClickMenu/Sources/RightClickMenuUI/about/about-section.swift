import SwiftUI

/// The part of settings that says what the app is and what changed.
///
/// Shows only the newest release. Somebody looking here wants to know what just
/// changed, not the whole history.
struct AboutPanel: View {

    let version: String
    let latest: Release?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AboutLayout.blockGap) {
                Text(UIText.version(version))
                    .font(.title3.weight(.semibold))

                if let latest {
                    Text(UIText.whatsNew)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: AboutLayout.noteGap) {
                        ForEach(latest.notes, id: \.self) { note in
                            NoteLine(note)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(FieldLayout.formPadding)
        }
    }
}

/// One line of what changed.
struct NoteLine: View {

    private let note: String

    /// Builds the line.
    ///
    /// - Parameter note: What changed. Already in the user's language.
    init(_ note: String) {
        self.note = note
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AboutLayout.bulletGap) {
            Text(AboutLayout.bullet)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(note)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

/// Fixed sizes and marks for the about part of settings.
enum AboutLayout {

    /// What starts each line of what changed.
    static let bullet = "•"

    /// The space between the mark and the words beside it.
    static let bulletGap: CGFloat = 8

    /// The space between the lines of what changed.
    static let noteGap: CGFloat = 6

    /// The space between the blocks on the panel.
    static let blockGap: CGFloat = 12
}
