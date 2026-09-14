import SwiftUI

/// A short message that appears over a screen and then goes away.
///
/// For things worth saying once and not worth a window of their own, such as a file
/// that could not be read. Holds no words of its own.
public struct Toast: View {

    private let message: String
    private let iconName: String

    /// Builds a message.
    ///
    /// - Parameters:
    ///   - message: What to say. Already in the user's language.
    ///   - iconName: A system symbol to put beside it.
    public init(message: String, iconName: String = ToastLayout.warningIconName) {
        self.message = message
        self.iconName = iconName
    }

    public var body: some View {
        Label(message, systemImage: iconName)
            .font(.callout)
            .padding(.horizontal, ToastLayout.sidePadding)
            .padding(.vertical, ToastLayout.topPadding)
            .background(.regularMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.separator))
            .shadow(radius: ToastLayout.shadow, y: ToastLayout.shadowDrop)
            .padding(.bottom, ToastLayout.bottomPadding)
    }
}

/// Fixed sizes and symbols for a short message.
public enum ToastLayout {

    /// The symbol shown beside something that went wrong.
    public static let warningIconName = "exclamationmark.triangle.fill"

    /// How far the words sit from the sides.
    static let sidePadding: CGFloat = 14

    /// How far the words sit from the top and bottom.
    static let topPadding: CGFloat = 9

    /// How soft the shadow is.
    static let shadow: CGFloat = 8

    /// How far the shadow falls.
    static let shadowDrop: CGFloat = 3

    /// How far the message sits from the bottom of the screen.
    static let bottomPadding: CGFloat = 22

    /// How long the message stays before it goes away, in seconds.
    public static let staysFor: Duration = .seconds(4)
}
