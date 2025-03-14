import SwiftUI
import hCore

public class ItemConfig<T>: ObservableObject where T: Equatable & Hashable {
    typealias PickerModel = (object: T, displayName: ItemModel)

    var items: [PickerModel]
    var preSelectedItems: [T]
    let onSelected: ([(object: T?, displayName: String?)]) -> Void
    let onCancel: (() -> Void)?
    let singleSelect: Bool?
    let attachToBottom: Bool
    let disableIfNoneSelected: Bool
    let manualInputPlaceholder: String
    let hButtonText: String
    let infoCard: ItemPickerInfoCard?
    let listTitle: String?
    let contentPosition: ContentPosition?
    let useAlwaysAttachedToBottom: Bool

    var fieldSize: hFieldSize
    let manualInputId = "manualInputId"

    @Published var type: ItemPickerFieldType? = nil
    @Published var manualBrandName: String = ""
    @Published var manualInput: Bool = false
    @Published var selectedItems: [T] = []

    public init(
        items: [(object: T, displayName: ItemModel)],
        preSelectedItems: @escaping () -> [T],
        onSelected: @escaping ([(T?, String?)]) -> Void,
        onCancel: (() -> Void)? = nil,
        singleSelect: Bool? = false,
        attachToBottom: Bool = false,
        disableIfNoneSelected: Bool = false,
        manualInputPlaceholder: String? = "",
        manualBrandName: String? = nil,
        withTitle: String? = nil,
        hButtonText: String? = L10n.generalSaveButton,
        infoCard: ItemPickerInfoCard? = nil,
        fieldSize: hFieldSize? = nil,
        contentPosition: ContentPosition? = nil,
        useAlwaysAttachedToBottom: Bool = false
    ) {
        self.items = items
        self.preSelectedItems = preSelectedItems()
        self.onSelected = onSelected
        self.onCancel = onCancel
        self.singleSelect = singleSelect
        self.listTitle = withTitle
        self.attachToBottom = attachToBottom
        self.disableIfNoneSelected = disableIfNoneSelected
        self.manualInputPlaceholder = manualInputPlaceholder ?? ""
        if let manualBrandName {
            self.manualBrandName = manualBrandName
            self.manualInput = true
        }
        self.hButtonText = hButtonText ?? L10n.generalSaveButton

        if fieldSize != nil {
            self.fieldSize = fieldSize ?? .large
        } else {
            if items.count > 3 {
                self.fieldSize = .small
            } else {
                self.fieldSize = .large
            }
        }

        self.infoCard = infoCard
        self.contentPosition = contentPosition
        self.useAlwaysAttachedToBottom = useAlwaysAttachedToBottom
        self.selectedItems = preSelectedItems()
    }

    public struct ItemPickerInfoCard {
        let text: String
        let buttons: [InfoCardButtonConfig]
        let placement: InfoCardPlacement

        public init(
            text: String,
            buttons: [InfoCardButtonConfig],
            placement: InfoCardPlacement
        ) {
            self.text = text
            self.buttons = buttons
            self.placement = placement
        }

        public enum InfoCardPlacement {
            case top
            case bottom
        }
    }
}

public struct ItemPickerScreen<T>: View where T: Equatable & Hashable {
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hItemPickerBottomAttachedView) var bottomAttachedView
    @Environment(\.hIncludeManualInput) var includeManualInput
    @ObservedObject private var config: ItemConfig<T>

    let leftView: ((T?) -> AnyView?)?
    public init(
        config: ItemConfig<T>,
        leftView: ((T?) -> AnyView?)? = nil
    ) {
        self.config = config
        self.leftView = leftView
    }

    @ViewBuilder
    public var body: some View {
        ScrollViewReader { proxy in
            if config.attachToBottom {
                hForm {}
                    .accessibilityLabel(
                        config.singleSelect ?? false
                            ? L10n.voiceoverPickerInfo(config.hButtonText)
                            : L10n.voiceoverPickerInfoMultiple(config.hButtonText)
                    )
                    .hFormContentPosition(config.contentPosition ?? .bottom)
                    .hFormAttachToBottom {
                        VStack(spacing: 0) {
                            VStack(spacing: .padding16) {
                                if let infoCard = config.infoCard, infoCard.placement == .top {
                                    hSection {
                                        InfoCard(text: infoCard.text, type: .info).buttons(infoCard.buttons)
                                    }
                                    .sectionContainerStyle(.transparent)
                                }
                                content(with: proxy)
                                if let infoCard = config.infoCard, infoCard.placement == .bottom {
                                    hSection {
                                        InfoCard(text: infoCard.text, type: .info).buttons(infoCard.buttons)
                                    }
                                    .sectionContainerStyle(.transparent)
                                }
                            }
                            bottomContent
                        }
                    }
                    .onAppear {
                        onAppear(with: proxy)
                    }
            } else {
                Group {
                    if config.useAlwaysAttachedToBottom {
                        hForm {
                            content(with: proxy)
                        }
                        .hFormAlwaysAttachToBottom {
                            bottomContent
                        }
                    } else {
                        hForm {
                            content(with: proxy)
                        }
                        .hFormAttachToBottom {
                            bottomContent
                        }
                    }
                }
                .hFormContentPosition(config.contentPosition ?? .compact)

                .onAppear {
                    onAppear(with: proxy)
                }
            }
        }
        .hFieldSize(config.fieldSize)
    }

    private func onAppear(with proxy: ScrollViewProxy) {
        if let selectedItem = config.selectedItems.first, config.selectedItems.count == 1 {
            proxy.scrollTo(selectedItem, anchor: .center)
        }

        if config.manualInput {
            proxy.scrollTo(config.manualInputId, anchor: .center)
        }
    }

    private func content(with proxy: ScrollViewProxy) -> some View {
        VStack(spacing: .padding4) {
            if let listTitle = config.listTitle {
                hSection(config.items, id: \.object) { item in
                    getCell(item: item.object)
                        .id(item.object)
                }
                .withHeader({
                    hText(listTitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                })
                .hEmbeddedHeader
                .disabled(isLoading)
            } else {
                ForEach(config.items, id: \.object) { item in
                    hSection {
                        getCell(item: item.object)
                            .id(item.object)
                    }
                    .disabled(isLoading)
                }
            }

            let showOtherCell = includeManualInput && !config.items.isEmpty
            let showFreeTextField = (config.manualInput && includeManualInput) || config.items.isEmpty

            if showOtherCell {
                hSection {
                    getCell(displayName: L10n.manualInputListOther)
                }
                .disabled(isLoading)
            }

            if showFreeTextField {
                hSection {
                    hFloatingTextField(
                        masking: Masking(type: .none),
                        value: $config.manualBrandName,
                        equals: $config.type,
                        focusValue: .inputField,
                        placeholder: config.manualInputPlaceholder
                    )
                }
                .onAppear {
                    config.manualInput = true
                    config.selectedItems = []
                }
                .id(config.manualInputId)
            }
        }
    }

    var accessibilityText: String {
        if config.selectedItems.isEmpty {
            if config.singleSelect ?? false {
                return L10n.voiceoverPickerInfo(config.hButtonText)
            }
            return L10n.voiceoverPickerInfoMultiple(config.hButtonText)
        }
        let selectedItemsDisplayName = config.selectedItems.map { selectedItem in
            config.items.first(where: { $0.object == selectedItem })?.displayName.title ?? ""
        }
        return L10n.voiceoverOptionSelected + selectedItemsDisplayName.joined()
    }

    var bottomContent: some View {
        hSection {
            VStack(spacing: 16) {
                bottomAttachedView

                hButton.LargeButton(type: .primary) {
                    sendSelectedItems
                } content: {
                    hText(config.hButtonText, style: .body1)
                }
                .hButtonIsLoading(isLoading)
                .disabled(config.disableIfNoneSelected ? config.selectedItems.isEmpty : false)
                .accessibilityHint(accessibilityText)
                if let onCancel = config.onCancel {
                    hButton.LargeButton(type: .ghost) {
                        onCancel()
                    } content: {
                        hText(L10n.generalCancelButton, style: .body1)
                    }
                    .disabled(isLoading)
                    .hButtonDontShowLoadingWhenDisabled(true)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, .padding16)
    }

    var sendSelectedItems: Void {
        if config.selectedItems.count > 1 {
            config.onSelected(
                config.selectedItems.map({
                    (object: $0, displayName: nil)
                })
            )
        } else if config.selectedItems.count == 0 {
            if config.manualInput && includeManualInput {
                config.onSelected([(object: nil, displayName: config.manualBrandName)])
            } else {
                config.onSelected([])
            }
        } else {
            if let object = config.selectedItems.first {
                config.onSelected([(object: object, displayName: nil)])
            }
        }
    }

    @ViewBuilder
    func getCell(item: T? = nil, displayName: String? = nil) -> some View {
        hRow {
            getCellContent(item, displayName)
        }
        .withEmptyAccessory
        .onTap {
            if let item {
                withAnimation(.easeInOut(duration: 0.2)) {
                    config.manualInput = false
                }
                onTapExecuteFor(item)
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    config.manualInput = true
                }
                config.selectedItems = []
                config.type = .inputField
            }
        }
    }

    @ViewBuilder
    func getCellContent(_ item: T?, _ itemDisplayName: String?) -> some View {
        let isSelected =
            config.selectedItems.first(where: { $0 == item }) != nil || (config.manualInput && itemDisplayName != nil)

        let displayName = config.items.first(where: { $0.object == item })?.displayName

        hFieldTextContent(
            item: displayName,
            fieldSize: config.fieldSize,
            itemDisplayName: itemDisplayName,
            leftViewWithItem: leftView,
            cellView: {
                AnyView(
                    selectionField(
                        isSelected: isSelected,
                        item,
                        itemDisplayName
                    )
                )
            }
        )
        .accessibilityHint(isSelected ? L10n.voiceoverOptionSelected + (displayName?.title ?? "") : "")
    }

    func onTapExecuteFor(_ item: T) {
        ImpactGenerator.soft()
        withAnimation(.easeInOut(duration: 0.2)) {
            if !(config.singleSelect ?? true) {
                if let index = self.config.selectedItems.firstIndex(where: { $0 == item }) {
                    config.selectedItems.remove(at: index)
                } else {
                    config.selectedItems.append(item)
                }
            } else {
                if let firstItem = config.selectedItems.first {
                    if !(firstItem == item) {
                        config.selectedItems = [item]
                    }
                } else {
                    config.selectedItems = [item]
                }
            }
        }
    }

    func selectionField(isSelected: Bool, _ item: T?, _ itemDisplayName: String?) -> some View {
        Group {
            ZStack {
                let isSelected =
                    config.selectedItems.first(where: { $0 == item }) != nil
                    || (config.manualInput && itemDisplayName != nil)
                var displayName = config.items.first(where: { $0.object == item })?.displayName

                if itemDisplayName == L10n.manualInputListOther {
                    let _ = displayName = .init(title: L10n.manualInputListOther, subTitle: nil)
                }
                getRightView(isSelected: isSelected, title: displayName?.title)
            }
        }
        .frame(width: 24, height: 24)
    }

    @ViewBuilder
    private func getRightView(isSelected: Bool, title: String?) -> some View {
        if let singleSelect = config.singleSelect, singleSelect {
            hRadioOptionSelectedView(
                selectedValue: .constant(isSelected ? title : nil),
                value: title ?? ""
            )
        } else {
            hRadioOptionSelectedView(
                selectedValue: .constant(isSelected ? title : nil),
                value: title ?? ""
            )
            .hUseCheckbox
        }
    }
}

struct ItemPickerScreen_Previews: PreviewProvider {
    struct ModelForPreview: Equatable, Hashable {
        let id: String
        let name: ItemModel
    }
    static var previews: some View {
        VStack {
            ItemPickerScreen<ModelForPreview>(
                config:
                    .init(
                        items: {
                            return [
                                ModelForPreview(id: "id", name: .init(title: "name1")),
                                ModelForPreview(id: "id2", name: .init(title: "title2", subTitle: "subtitle2")),
                                ModelForPreview(
                                    id: "id3",
                                    name: .init(title: "title3", subTitle: "subtitle3")
                                ),
                                ModelForPreview(id: "id4", name: .init(title: "name4")),
                                ModelForPreview(id: "id5", name: .init(title: "name5")),
                                ModelForPreview(id: "id6", name: .init(title: "name6")),
                                ModelForPreview(id: "id7", name: .init(title: "name7")),

                            ]
                            .compactMap({ (object: $0, displayName: $0.name) })
                        }(),
                        preSelectedItems: { [] },
                        onSelected: { selectedLocation in

                        },
                        onCancel: {
                        },
                        singleSelect: true,
                        attachToBottom: true,
                        manualInputPlaceholder: "Enter brand name",
                        withTitle: "Label",
                        fieldSize: .small
                    ),
                leftView: { _ in
                    Image(uiImage: hCoreUIAssets.pillowHome.image)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .asAnyView
                }
            )
            .hEmbeddedHeader
            .hIncludeManualInput
        }
    }
}

private struct EnvironmentHItemPickerBottomAttachedView: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hItemPickerBottomAttachedView: AnyView? {
        get { self[EnvironmentHItemPickerBottomAttachedView.self] }
        set { self[EnvironmentHItemPickerBottomAttachedView.self] = newValue }
    }
}

extension View {
    public func hItemPickerBottomAttachedView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hItemPickerBottomAttachedView, AnyView(content()))
    }
}

enum ItemPickerFieldType: hTextFieldFocusStateCompliant {
    static var last: ItemPickerFieldType {
        return ItemPickerFieldType.inputField
    }

    var next: ItemPickerFieldType? {
        switch self {
        case .inputField:
            return nil
        case .none:
            return nil
        }
    }

    case inputField
    case none
}

private struct EnvironmentHIncludeManualInput: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hIncludeManualInput: Bool {
        get { self[EnvironmentHIncludeManualInput.self] }
        set { self[EnvironmentHIncludeManualInput.self] = newValue }
    }
}

extension View {
    public var hIncludeManualInput: some View {
        self.environment(\.hIncludeManualInput, true)
    }
}

private struct EnvironmentHLeftAlign: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hFieldLeftAttachedView: Bool {
        get { self[EnvironmentHLeftAlign.self] }
        set { self[EnvironmentHLeftAlign.self] = newValue }
    }
}

extension View {
    public var hFieldLeftAttachedView: some View {
        self.environment(\.hFieldLeftAttachedView, true)
    }
}

private struct EnvironmentHUseCheckbox: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hUseCheckbox: Bool {
        get { self[EnvironmentHUseCheckbox.self] }
        set { self[EnvironmentHUseCheckbox.self] = newValue }
    }
}

extension View {
    public var hUseCheckbox: some View {
        self.environment(\.hUseCheckbox, true)
    }
}
