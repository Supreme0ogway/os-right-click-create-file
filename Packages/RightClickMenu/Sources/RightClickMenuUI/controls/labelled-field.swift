import SwiftUI

/// A row with a label above a place to type.
///
/// The label sits at the left, with a short line under the field saying what is
/// allowed and, when something is wrong, what is wrong with it.
///
/// Built from the system's own field, so keyboard, focus and screen readers come free.
/// Holds no words of its own: everything shown is passed in, already looked up.
public struct LabelledField: View {

    private let label: String
    private let placeholder: String
    private let hint: String
    private let problem: String?
    @Binding private var text: String

    /// Builds a labelled row.
    ///
    /// - Parameters:
    ///   - label: What the row is called. Already in the user's language.
    ///   - placeholder: What to show while the field is empty.
    ///   - hint: A few words under the field saying what is allowed.
    ///   - problem: What is wrong, or `nil` when nothing is.
    ///   - text: The text being edited.
    public init(
        label: String,
        placeholder: String = "",
        hint: String = "",
        problem: String? = nil,
        text: Binding<String>
    ) {
        self.label = label
        self.placeholder = placeholder
        self.hint = hint
        self.problem = problem
        self._text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FieldLayout.lineGap) {
            FieldLabel(label)

            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)

            if let problem {
                Text(problem)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if problem == nil, !hint.isEmpty {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// The left aligned label that starts a form row.
public struct FieldLabel: View {

    private let text: String

    /// Builds a label.
    ///
    /// - Parameter text: What the row is called. Already in the user's language.
    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Fixed sizes shared by every form row.
public enum FieldLayout {

    /// The space between the parts of one row.
    public static let lineGap: CGFloat = 4

    /// The space between one row and the next.
    public static let rowGap: CGFloat = 16

    /// The space around a whole form.
    public static let formPadding: CGFloat = 20
}
