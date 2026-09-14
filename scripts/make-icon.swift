import AppKit

/// Draws the app's icon and writes every size a mac asks for.
///
/// Run through `scripts/make-icon.sh`, which turns what this writes into the icon file
/// the app carries. Kept as a drawing rather than a picture so the icon can be changed
/// by editing numbers, and so nothing binary has to be read to know what it looks like.

/// Fixed facts about how the icon is drawn.
enum IconDesign {

    /// The side of the square the icon is drawn on, before it is scaled down.
    static let canvas: CGFloat = 1024

    /// How much clear space a mac icon leaves around itself.
    static let margin: CGFloat = 100

    /// How round the corners of the tile are.
    static let cornerRadius: CGFloat = 200

    /// The blue at the top of the tile.
    static let tileTop = NSColor(srgbRed: 0.35, green: 0.53, blue: 1.00, alpha: 1)

    /// The deeper blue at the bottom of the tile.
    static let tileBottom = NSColor(srgbRed: 0.16, green: 0.27, blue: 0.80, alpha: 1)

    /// The page drawn on the tile.
    static let pageColor = NSColor.white

    /// How wide the page is, as a share of the tile.
    static let pageWidthShare: CGFloat = 0.52

    /// How tall the page is, as a share of the tile.
    static let pageHeightShare: CGFloat = 0.64

    /// How big the folded corner of the page is, as a share of the page width.
    static let foldShare: CGFloat = 0.34

    /// How long each arm of the plus is, as a share of the page width.
    static let plusArmShare: CGFloat = 0.46

    /// How thick the plus is, as a share of the page width.
    static let plusThicknessShare: CGFloat = 0.14

    /// The sizes a mac icon file holds, each written at one and two times.
    static let sizes: [Int] = [16, 32, 128, 256, 512]
}

/// Draws the icon once, at the full canvas size.
func drawIcon(into context: CGContext) {
    let canvas = IconDesign.canvas
    let inset = IconDesign.margin
    let tile = CGRect(x: inset, y: inset, width: canvas - inset * 2, height: canvas - inset * 2)

    drawTile(tile, into: context)

    let pageWidth = tile.width * IconDesign.pageWidthShare
    let pageHeight = tile.height * IconDesign.pageHeightShare
    let page = CGRect(
        x: tile.midX - pageWidth / 2,
        y: tile.midY - pageHeight / 2,
        width: pageWidth,
        height: pageHeight
    )

    drawPage(page, into: context)
    drawPlus(on: page, into: context)
}

private func drawTile(_ tile: CGRect, into context: CGContext) {
    let path = CGPath(
        roundedRect: tile,
        cornerWidth: IconDesign.cornerRadius,
        cornerHeight: IconDesign.cornerRadius,
        transform: nil
    )
    context.saveGState()
    context.addPath(path)
    context.clip()

    let colors = [IconDesign.tileBottom.cgColor, IconDesign.tileTop.cgColor] as CFArray
    guard let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: colors,
        locations: [0, 1]
    ) else {
        context.restoreGState()
        return
    }
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: tile.midX, y: tile.minY),
        end: CGPoint(x: tile.midX, y: tile.maxY),
        options: []
    )
    context.restoreGState()
}

private func drawPage(_ page: CGRect, into context: CGContext) {
    let fold = page.width * IconDesign.foldShare
    let body = CGMutablePath()
    body.move(to: CGPoint(x: page.minX, y: page.minY))
    body.addLine(to: CGPoint(x: page.maxX, y: page.minY))
    body.addLine(to: CGPoint(x: page.maxX, y: page.maxY - fold))
    body.addLine(to: CGPoint(x: page.maxX - fold, y: page.maxY))
    body.addLine(to: CGPoint(x: page.minX, y: page.maxY))
    body.closeSubpath()

    context.setFillColor(IconDesign.pageColor.cgColor)
    context.addPath(body)
    context.fillPath()

    let corner = CGMutablePath()
    corner.move(to: CGPoint(x: page.maxX - fold, y: page.maxY))
    corner.addLine(to: CGPoint(x: page.maxX - fold, y: page.maxY - fold))
    corner.addLine(to: CGPoint(x: page.maxX, y: page.maxY - fold))
    corner.closeSubpath()

    context.setFillColor(IconDesign.tileTop.withAlphaComponent(0.45).cgColor)
    context.addPath(corner)
    context.fillPath()
}

private func drawPlus(on page: CGRect, into context: CGContext) {
    let arm = page.width * IconDesign.plusArmShare
    let thickness = page.width * IconDesign.plusThicknessShare
    let centre = CGPoint(x: page.midX, y: page.midY - page.height * 0.05)

    let across = CGRect(
        x: centre.x - arm / 2,
        y: centre.y - thickness / 2,
        width: arm,
        height: thickness
    )
    let down = CGRect(
        x: centre.x - thickness / 2,
        y: centre.y - arm / 2,
        width: thickness,
        height: arm
    )

    context.setFillColor(IconDesign.tileBottom.cgColor)
    for bar in [across, down] {
        context.addPath(
            CGPath(
                roundedRect: bar,
                cornerWidth: thickness / 2,
                cornerHeight: thickness / 2,
                transform: nil
            )
        )
    }
    context.fillPath()
}

/// Writes one square picture of the icon.
func writePNG(side: Int, to url: URL) throws {
    guard let context = CGContext(
        data: nil,
        width: side,
        height: side,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { throw IconError.cannotDraw }

    let scale = CGFloat(side) / IconDesign.canvas
    context.scaleBy(x: scale, y: scale)
    context.setAllowsAntialiasing(true)
    drawIcon(into: context)

    guard let image = context.makeImage() else { throw IconError.cannotDraw }
    let rep = NSBitmapImageRep(cgImage: image)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw IconError.cannotDraw
    }
    try data.write(to: url)
}

/// Why the icon could not be made.
enum IconError: Error {
    case cannotDraw
    case noDestination
}

let arguments = CommandLine.arguments
guard arguments.count > 1 else { throw IconError.noDestination }
let iconset = URL(filePath: arguments[1])
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

for size in IconDesign.sizes {
    try writePNG(side: size, to: iconset.appending(path: "icon_\(size)x\(size).png"))
    try writePNG(side: size * 2, to: iconset.appending(path: "icon_\(size)x\(size)@2x.png"))
}
print("drew \(IconDesign.sizes.count * 2) sizes into \(iconset.path)")
