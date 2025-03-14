import SwiftUI
import hCore

public class ItemManualInput {
    let id = "manualInputId"
    let placeholder: String?
    @Published public var brandName: String = ""
    @Published var input: Bool = false

    public init(
        placeholder: String? = nil,
        brandName: String? = nil
    ) {
        self.placeholder = placeholder
        if let brandName {
            self.brandName = brandName
            self.input = true
        }
    }
}

public class ItemConfig<T>: ObservableObject where T: Equatable & Hashable {
    typealias PickerModel = (object: T, displayName: ItemModel)

    var items: [PickerModel]
    var preSelectedItems: [T]
    let onSelected: ([(object: T?, displayName: String?)]) -> Void
    let onCancel: (() -> Void)?
    let buttonText: String
    let infoCard: ItemPickerInfoCard?
    let contentPosition: ContentPosition?
    var manualInput: ItemManualInput

    @Published var type: ItemPickerFieldType? = nil
    @Published var selectedItems: [T] = []

    public init(
        items: [(object: T, displayName: ItemModel)],
        preSelectedItems: @escaping () -> [T],
        onSelected: @escaping ([(T?, String?)]) -> Void,
        onCancel: (() -> Void)? = nil,
        manualInputConfig: ItemManualInput? = nil,
        buttonText: String? = L10n.generalSaveButton,
        infoCard: ItemPickerInfoCard? = nil,
        contentPosition: ContentPosition? = nil
    ) {
        self.items = items
        self.preSelectedItems = preSelectedItems()
        self.onSelected = onSelected
        self.onCancel = onCancel
        self.manualInput = manualInputConfig ?? .init(placeholder: nil)
        self.buttonText = buttonText ?? L10n.generalSaveButton
        self.infoCard = infoCard
        self.contentPosition = contentPosition
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
    @Environment(\.hItemPickerAttributes) var attributes
    @Environment(\.hFieldSize) var fieldSize
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
            if attributes.contains(.attachToBottom) {
                hForm {}
                    .accessibilityLabel(
                        attributes.contains(.singleSelect)
                            ? L10n.voiceoverPickerInfo(config.buttonText)
                            : L10n.voiceoverPickerInfoMultiple(config.buttonText)
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
                    if attributes.contains(.alwaysAttachToBottom) {
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
        .hFieldSize(fieldSize)
    }

    private func onAppear(with proxy: ScrollViewProxy) {
        if let selectedItem = config.selectedItems.first, config.selectedItems.count == 1 {
            proxy.scrollTo(selectedItem, anchor: .center)
        }

        if config.manualInput.input {
            proxy.scrollTo(config.manualInput.id, anchor: .center)
        }
    }

    private func content(with proxy: ScrollViewProxy) -> some View {
        VStack(spacing: .padding4) {
            ForEach(config.items, id: \.object) { item in
                hSection {
                    getCell(item: item.object)
                        .id(item.object)
                }
                .disabled(isLoading)
            }

            let showOtherCell = config.manualInput.placeholder != nil && !config.items.isEmpty
            let showFreeTextField = config.manualInput.input || config.items.isEmpty

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
                        value: $config.manualInput.brandName,
                        equals: $config.type,
                        focusValue: .inputField,
                        placeholder: config.manualInput.placeholder
                    )
                }
                .onAppear {
                    config.manualInput.input = true
                    config.selectedItems = []
                }
                .id(config.manualInput.id)
            }
        }
    }

    var accessibilityText: String {
        if config.selectedItems.isEmpty {
            if attributes.contains(.singleSelect) {
                return L10n.voiceoverPickerInfo(config.buttonText)
            }
            return L10n.voiceoverPickerInfoMultiple(config.buttonText)
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
                    hText(config.buttonText, style: .body1)
                }
                .hButtonIsLoading(isLoading)
                .disabled(attributes.contains(.disableIfNoneSelected) ? config.selectedItems.isEmpty : false)
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
            if config.manualInput.input {
                config.onSelected([(object: nil, displayName: config.manualInput.brandName)])
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
                    config.manualInput.input = false
                }
                onTapExecuteFor(item)
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    config.manualInput.input = true
                }
                config.selectedItems = []
                config.type = .inputField
            }
        }
    }

    @ViewBuilder
    func getCellContent(_ item: T?, _ itemDisplayName: String?) -> some View {
        let isSelected =
            config.selectedItems.first(where: { $0 == item }) != nil
            || (config.manualInput.input && itemDisplayName != nil)

        let displayName = config.items.first(where: { $0.object == item })?.displayName

        hFieldTextContent(
            item: displayName,
            fieldSize: fieldSize,
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
            if !attributes.contains(.singleSelect) {
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
                    || (config.manualInput.input && itemDisplayName != nil)
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
        if attributes.contains(.singleSelect) {
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
                        manualInputConfig: .init(placeholder: "Enter brand name"),
                        buttonText: L10n.generalSaveButton
                    ),
                leftView: { _ in
                    Image(uiImage: hCoreUIAssets.pillowHome.image)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .asAnyView
                }
            )
            .hItemPickerAttributes([.singleSelect, .attachToBottom])
            .hFieldSize(.small)
            .hEmbeddedHeader
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

public enum ItemPickerAttribute {
    case singleSelect
    case disableIfNoneSelected
    case attachToBottom
    case alwaysAttachToBottom
}

private struct EnvironmentHItemPickerAttributes: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: [ItemPickerAttribute] = []
}

extension EnvironmentValues {
    public var hItemPickerAttributes: [ItemPickerAttribute] {
        get { self[EnvironmentHItemPickerAttributes.self] }
        set { self[EnvironmentHItemPickerAttributes.self] = newValue }
    }
}

extension View {
    public func hItemPickerAttributes(_ attributes: [ItemPickerAttribute]) -> some View {
        self.environment(\.hItemPickerAttributes, attributes)
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
