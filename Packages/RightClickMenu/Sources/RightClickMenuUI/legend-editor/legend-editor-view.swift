import SwiftUI

/// The screen where file types are added, changed and removed.
///
/// Opens with nothing picked, so the window says what it holds before it says what one
/// row of it says.
///
/// Layout only. Every rule about what may be added, what an added type is called and
/// what happens when the last one goes lives in the model this reads from.
public struct LegendEditorView: View {

    @State private var model: LegendEditorViewModel
    @State private var picked: FileTypeIdentifier?
    @State private var isAdding = false

    @Environment(\.colorScheme) private var appearance

    private let preferences: RecordStore<Preferences>
    private let onOpenSettings: () -> Void

    /// Builds the screen.
    ///
    /// - Parameters:
    ///   - model: What the screen knows and can do.
    ///   - preferences: The choices the app remembers between launches.
    ///   - onOpenSettings: What to do when the settings button is pressed.
    public init(
        model: LegendEditorViewModel,
        preferences: RecordStore<Preferences>,
        onOpenSettings: @escaping () -> Void
    ) {
        self._model = State(initialValue: model)
        self.preferences = preferences
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        NavigationSplitView {
            typeList
        } detail: {
            detail
        }
        .navigationTitle(UIText.appName)
        .searchable(text: $model.search, placement: .toolbar, prompt: UIText.search)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(UIText.addType, systemImage: EditorLayout.addIconName) { isAdding = true }
                Button(
                    UIText.settings,
                    systemImage: EditorLayout.settingsIconName,
                    action: onOpenSettings
                )
            }
        }
        .sheet(isPresented: $isAdding) { addSheet }
        .alert(
            UIText.removeQuestion(model.pendingRemovalName),
            isPresented: askingToRemove
        ) {
            Button(UIText.removeCancel, role: .cancel) { model.cancelRemoval() }
            Button(UIText.removeConfirm, role: .destructive) { model.confirmRemoval() }
        } message: {
            Text(UIText.removeWarning)
        }
    }

    private var addSheet: some View {
        AddTypeSheet(
            model: AddTypeViewModel(
                known: BuiltInLegend.knownTypes(),
                taken: Set(model.types.map(\.id)),
                preferences: preferences
            ),
            onAdd: { type in
                model.add(type)
                picked = type.id
                isAdding = false
            },
            onCancel: { isAdding = false }
        )
    }

    private var typeList: some View {
        List(selection: $picked) {
            ForEach(model.shownTypes) { type in
                TypeRow(type: type, appearance: appearance)
                    .tag(type.id)
                    .contextMenu {
                        Button(UIText.removeConfirm, role: .destructive) {
                            model.askToRemove(type.id)
                        }
                    }
            }
            .onMove(perform: model.move)
            .moveDisabled(!model.canReorder)
        }
        .overlay { listOverlay }
        .navigationSplitViewColumnWidth(
            min: EditorLayout.listMinimumWidth,
            ideal: EditorLayout.listIdealWidth
        )
    }

    @ViewBuilder
    private var listOverlay: some View {
        if model.showsEmptyMessage {
            EmptyState(
                title: UIText.emptyTitle,
                message: UIText.emptyMessage,
                iconName: EditorLayout.emptyIconName
            )
        }

        if model.showsNoMatchesMessage {
            EmptyState(
                title: UIText.noMatchesTitle,
                message: UIText.noMatchesMessage,
                iconName: EditorLayout.noMatchesIconName
            )
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let type = pickedType {
            FileTypeForm(type: type, model: model)
                .id(type.id)
        }

        if pickedType == nil, !model.showsEmptyMessage {
            EmptyState(
                title: UIText.nothingPickedTitle,
                message: UIText.nothingPickedMessage,
                iconName: EditorLayout.nothingPickedIconName
            )
        }
    }

    private var askingToRemove: Binding<Bool> {
        Binding(
            get: { model.isAskingToRemove },
            set: { stillAsking in
                guard !stillAsking else { return }
                model.cancelRemoval()
            }
        )
    }

    private var pickedType: FileType? {
        guard let picked else { return nil }
        return model.types.first { $0.id == picked }
    }
}

/// Fixed sizes and symbols for the editor screen.
enum EditorLayout {

    /// The narrowest the list of types may get.
    static let listMinimumWidth: CGFloat = 180

    /// How wide the list of types opens.
    static let listIdealWidth: CGFloat = 220

    /// How tall the box holding the starting text is.
    static let templateHeight: CGFloat = 140

    /// The symbol shown when there are no types left.
    static let emptyIconName = "tray"

    /// The symbol shown when no type has been picked.
    static let nothingPickedIconName = "hand.point.left"

    /// The symbol on the button that adds a type.
    static let addIconName = "plus"

    /// The symbol on the button that removes a type.
    static let removeIconName = "trash"

    /// How wide the floating remove button is.
    static let bubbleSize: CGFloat = 44

    /// How big the trash on the floating remove button is.
    static let bubbleIconSize: CGFloat = 17

    /// How far the floating remove button sits from the corner.
    static let bubblePadding: CGFloat = 18

    /// How soft the floating remove button's shadow is.
    static let bubbleShadow: CGFloat = 6

    /// How far the floating remove button's shadow falls.
    static let bubbleShadowDrop: CGFloat = 2

    /// The symbol on the button that opens the settings screen.
    static let settingsIconName = "gearshape"

    /// The symbol shown when a search matched nothing.
    static let noMatchesIconName = "magnifyingglass"
}
