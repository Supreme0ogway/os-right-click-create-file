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

    /// The color across the top of a window.
    ///
    /// Full color at the left, where the title sits, fading to nothing a little past
    /// it. Nothing else in the window is colored: the list and the panel keep the
    /// system's own background.
    public static let band = LinearGradient(
        stops: [
            .init(color: deep, location: 0),
            .init(color: light, location: BrandBand.fadeStart),
            .init(color: light.opacity(0), location: BrandBand.fadeEnd),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

/// Where the color across the top of a window fades out.
enum BrandBand {

    /// How far along the band the color starts to go, as a share of the width.
    static let fadeStart = 0.18

    /// How far along the band the color is gone, as a share of the width.
    static let fadeEnd = 0.38
}
