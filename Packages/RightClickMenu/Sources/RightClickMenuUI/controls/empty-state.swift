import SwiftUI

/// What a screen shows when there is deliberately nothing to show.
///
/// Says that the emptiness is allowed and what it means, so a list somebody emptied
/// on purpose does not read as a fault. Holds no words of its own.
public struct EmptyState: View {

    private let title: String
    private let message: String
    private let iconName: String

    /// Builds an empty state.
    ///
    /// - Parameters:
    ///   - title: The short line. Already in the user's language.
    ///   - message: The sentence explaining what empty means here.
    ///   - iconName: A system symbol to show above the words.
    public init(title: String, message: String, iconName: String) {
        self.title = title
        self.message = message
        self.iconName = iconName
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: iconName)
        } description: {
            Text(message)
        }
    }
}
