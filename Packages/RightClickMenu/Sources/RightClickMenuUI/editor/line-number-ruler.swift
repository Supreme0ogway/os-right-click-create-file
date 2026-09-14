import AppKit

/// The strip of line numbers down the left of the editor.
///
/// Counts the newlines before each visible line rather than keeping a list, so nothing
/// has to be kept in step as the text changes.
final class LineNumberRuler: NSRulerView {

    /// Builds a ruler for a text view.
    ///
    /// - Parameter textView: The view whose lines are being counted.
    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)
        clientView = textView
        ruleThickness = RulerLayout.width
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("This ruler is only ever made in code.")
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = clientView as? NSTextView,
              let layout = textView.layoutManager,
              let container = textView.textContainer
        else { return }

        let text = textView.string as NSString
        let visible = layout.glyphRange(forBoundingRect: visibleRect, in: container)
        let inset = textView.textContainerInset.height

        var lineStart = 0
        var number = 1
        while lineStart < text.length {
            let lineRange = text.lineRange(for: NSRange(location: lineStart, length: 0))
            defer {
                lineStart = NSMaxRange(lineRange)
                number += 1
            }
            guard NSLocationInRange(lineRange.location, visible) else { continue }

            let used = layout.lineFragmentRect(
                forGlyphAt: layout.glyphIndexForCharacter(at: lineRange.location),
                effectiveRange: nil
            )
            draw(number, atY: used.minY + inset - convert(NSPoint.zero, from: textView).y)
        }

        guard text.length == 0 || text.hasSuffix("\n") else { return }
        draw(number, atY: layout.usedRect(for: container).maxY + inset
            - convert(NSPoint.zero, from: textView).y)
    }

    private func draw(_ number: Int, atY top: CGFloat) {
        let label = "\(number)" as NSString
        let style = [
            NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(
                ofSize: RulerLayout.fontSize,
                weight: .regular
            ),
            .foregroundColor: NSColor.tertiaryLabelColor,
        ]
        let size = label.size(withAttributes: style)
        label.draw(
            at: NSPoint(x: RulerLayout.width - size.width - RulerLayout.gap, y: top),
            withAttributes: style
        )
    }
}

/// Fixed sizes for the strip of line numbers.
enum RulerLayout {

    /// How wide the strip is.
    static let width: CGFloat = 36

    /// How big the numbers are.
    static let fontSize: CGFloat = 11

    /// The space between a number and the text it counts.
    static let gap: CGFloat = 6
}
