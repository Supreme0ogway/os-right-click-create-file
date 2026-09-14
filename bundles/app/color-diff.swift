import AppKit

/// The band of app color across the top of the window.
///
/// It is put into the title bar's own layer, underneath the title and the buttons, so
/// it colors that strip and nothing else. The window's own background is left alone:
/// coloring that instead shows through the list, which is translucent, and floods the
/// whole window.
///
/// Full color at the right hand edge, thinning as it runs left and completely gone by
/// the time it reaches the list on the left, so no color ever sits behind that list.
///
/// The band is inset from the left by the width of that list rather than faded by a
/// share of the window, so widening the window does not drag color back over it.
@MainActor
enum ColorDiff {

    /// Puts the band into a window's title bar.
    ///
    /// - Parameter window: The window to color.
    static func apply(to window: NSWindow) {
        guard let titlebar = window.standardWindowButton(.closeButton)?.superview else { return }

        titlebar.wantsLayer = true
        titlebar.layer?.sublayers?
            .filter { $0.name == ColorDiffLook.layerName }
            .forEach { $0.removeFromSuperlayer() }

        titlebar.layer?.insertSublayer(band(in: titlebar.bounds), at: 0)
    }

    private static func band(in bounds: CGRect) -> CAGradientLayer {
        let left = ColorDiffLook.listWidth
        let layer = CAGradientLayer()
        layer.name = ColorDiffLook.layerName
        layer.frame = CGRect(
            x: left,
            y: 0,
            width: max(0, bounds.width - left),
            height: bounds.height
        )
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer.colors = [
            ColorDiffLook.light.withAlphaComponent(0).cgColor,
            ColorDiffLook.light.cgColor,
            ColorDiffLook.deep.cgColor,
        ]
        layer.locations = [0, ColorDiffLook.midpoint, 1]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }
}

/// The colors and shape of the band. The same blue as the app's icon.
enum ColorDiffLook {

    /// The name the band's layer is known by, so it is replaced rather than stacked.
    static let layerName = "color-diff"

    /// The blue through the middle of the band.
    static let light = NSColor(srgbRed: 0.35, green: 0.53, blue: 1.00, alpha: 1)

    /// The deeper blue at the right hand edge.
    static let deep = NSColor(srgbRed: 0.16, green: 0.27, blue: 0.80, alpha: 1)

    /// How wide the list on the left is, which the band starts to the right of.
    static let listWidth: CGFloat = 220

    /// How far across the band the color has come fully in.
    static let midpoint: NSNumber = 0.55
}
