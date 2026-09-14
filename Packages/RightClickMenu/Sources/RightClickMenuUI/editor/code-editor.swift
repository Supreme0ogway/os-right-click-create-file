import AppKit
import Highlightr
import SwiftUI

/// The box a file's starting contents are typed into.
///
/// A real editor rather than a plain box: it counts the lines down the side and colors
/// the text the way the extension says it should be read. An extension nobody knows
/// leaves the text plain, which is not a fault.
///
/// - Note: The coloring rewrites the whole text's styling, so it is done as the text
///   changes rather than on every keystroke's layout pass.
public struct CodeEditor: NSViewRepresentable {

    @Binding private var text: String

    private let fileExtension: String

    /// Builds the editor.
    ///
    /// - Parameters:
    ///   - text: What is being typed.
    ///   - fileExtension: Decides how the text is colored.
    public init(text: Binding<String>, fileExtension: String) {
        self._text = text
        self.fileExtension = fileExtension
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let storage = CodeAttributedString()
        storage.language = CodeLanguage.forExtension(fileExtension)

        let layout = NSLayoutManager()
        let container = NSTextContainer()
        container.widthTracksTextView = true
        layout.addTextContainer(container)
        storage.addLayoutManager(layout)

        let textView = NSTextView(frame: .zero, textContainer: container)
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.font = .monospacedSystemFont(ofSize: CodeEditorLayout.fontSize, weight: .regular)
        textView.textContainerInset = NSSize(
            width: CodeEditorLayout.inset,
            height: CodeEditorLayout.inset
        )
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.string = text

        let scroll = NSScrollView()
        scroll.documentView = textView
        scroll.hasVerticalScroller = true
        scroll.borderType = .bezelBorder
        scroll.autohidesScrollers = true
        scroll.translatesAutoresizingMaskIntoConstraints = false

        scroll.hasVerticalRuler = true
        scroll.verticalRulerView = LineNumberRuler(textView: textView)
        scroll.rulersVisible = true

        scroll.heightAnchor
            .constraint(equalToConstant: CodeEditorLayout.height)
            .isActive = true

        context.coordinator.textView = textView
        context.coordinator.storage = storage
        return scroll
    }

    public func updateNSView(_ scroll: NSScrollView, context: Context) {
        context.coordinator.text = $text
        context.coordinator.storage?.language = CodeLanguage.forExtension(fileExtension)

        guard let textView = context.coordinator.textView, textView.string != text else { return }
        textView.string = text
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    /// Carries what was typed back out, and holds on to the views between updates.
    public final class Coordinator: NSObject, NSTextViewDelegate {

        var text: Binding<String>
        weak var textView: NSTextView?
        var storage: CodeAttributedString?

        init(text: Binding<String>) {
            self.text = text
        }

        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
            textView.enclosingScrollView?.verticalRulerView?.needsDisplay = true
        }
    }
}

/// Fixed sizes for the editor.
enum CodeEditorLayout {

    /// How big the typed text is.
    static let fontSize: CGFloat = 12

    /// The space between the text and the edge of the box.
    static let inset: CGFloat = 6

    /// How tall the box is.
    static let height: CGFloat = 220
}
