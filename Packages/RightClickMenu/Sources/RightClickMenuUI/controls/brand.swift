import SwiftUI

/// The app's own colors.
///
/// The same blue as the icon, so a window that has no dock icon behind it is still
/// plainly this app and not a system panel.
public enum Brand {

    /// The blue at the top of the icon's tile.
    public static let light = Color(.sRGB, red: 0.35, green: 0.53, blue: 1.00)

    /// The deeper blue at the bottom of the icon's tile.
    public static let deep = Color(.sRGB, red: 0.16, green: 0.27, blue: 0.80)

    /// The icon's tile, as a band to put behind the top of a window.
    public static let band = LinearGradient(
        colors: [light, deep],
        startPoint: .leading,
        endPoint: .trailing
    )
}
