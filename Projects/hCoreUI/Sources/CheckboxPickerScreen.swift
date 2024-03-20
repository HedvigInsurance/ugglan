import SwiftUI
import hCore

public struct DisplayString: Hashable {
    let title: String
    let subTitle: String?
    let extraSubTitle: String?

    public init(
        title: String,
        subTitle: String? = nil,
        extraSubTitle: String? = nil
    ) {
        self.title = title
        self.subTitle = subTitle
        self.extraSubTitle = extraSubTitle
    }
}

public struct CheckboxPickerScreen<T>: View where T: Equatable & Hashable {
    typealias PickerModel = (object: T, displayName: DisplayString)
    private var items: [PickerModel]
    private let preSelectedItems: [T]
    private let onSelected: ([(object: T?, displayName: String?)]) -> Void
    private let onCancel: (() -> Void)?
    private let singleSelect: Bool?
    private let showDividers: Bool?
    private let attachToBottom: Bool
    private let disableIfNoneSelected: Bool
    private let manualInputPlaceholder: String
    private let hButtonText: String
    private let infoCard: CheckboxInfoCard?
    private var title: String?
    private var titleMarker: String?
    private var subTitle: String?

    @State var type: CheckboxFieldType? = nil

    @State private var selectedItems: [T] = []
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hCheckboxPickerBottomAttachedView) var bottomAttachedView
    @Environment(\.hIncludeManualInput) var includeManualInput
    @Environment(\.hUseColoredCheckbox) var coloredCheckBox

    @State var manualBrandName: String = ""
    @State var manualInput: Bool = false

    private var fieldSize: hFieldSize
    private let manualInputId = "manualInputId"
    public init(
        items: [(object: T, displayName: DisplayString)],
        preSelectedItems: @escaping () -> [T],
        onSelected: @escaping ([(T?, String?)]) -> Void,
        onCancel: (() -> Void)? = nil,
        singleSelect: Bool? = false,
        showDividers: Bool? = false,
        attachToBottom: Bool = false,
        disableIfNoneSelected: Bool = false,
        manualInputPlaceholder: String? = "",
        manualBrandName: String? = nil,
        hButtonText: String? = L10n.generalSaveButton,
        infoCard: CheckboxInfoCard? = nil,
        title: String? = nil,
        titleMarker: String? = nil,
        subTitle: String? = nil
    ) {
        self.items = items
        self.preSelectedItems = preSelectedItems()
        self.onSelected = onSelected
        self.onCancel = onCancel
        self.singleSelect = singleSelect
        self.showDividers = showDividers
        self.attachToBottom = attachToBottom
        self.disableIfNoneSelected = disableIfNoneSelected
        self.manualInputPlaceholder = manualInputPlaceholder ?? ""
        if let manualBrandName {
            self.manualBrandName = manualBrandName
            self.manualInput = true
        }
        self.hButtonText = hButtonText ?? L10n.generalSaveButton
        if items.count > 3 {
            self.fieldSize = .small
        } else {
            self.fieldSize = .large
        }
        self.infoCard = infoCard
        self.title = title
        self.titleMarker = titleMarker
        self.subTitle = subTitle
    }

    @ViewBuilder
    public var body: some View {
        ScrollViewReader { proxy in
            if attachToBottom {
                hForm {
                    hSection {
                        VStack {
                            Group {
                                HStack(spacing: 8) {
                                    if let title {
                                        hText(title, style: .title3)
                                    }
                                    if let titleMarker {
                                        HStack {
                                            hText(titleMarker)
                                                .foregroundColor(hTextColor.secondary)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(
                                            Squircle.default()
                                                .fill(hFillColor.opaqueOne)
                                        )
                                    }
                                }

                                if let subTitle {
                                    hText(subTitle, style: .title3)
                                        .foregroundColor(hTextColor.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
                .hFormAttachToBottom {
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {
                            if let infoCard, infoCard.placement == .top {
                                hSection {
                                    InfoCard(text: infoCard.text, type: .info).buttons(infoCard.buttons)
                                }
                                .sectionContainerStyle(.transparent)
                            }
                            content(with: proxy)
                            if let infoCard, infoCard.placement == .bottom {
                                hSection {
                                    InfoCard(text: infoCard.text, type: .info).buttons(infoCard.buttons)
                                }
                                .sectionContainerStyle(.transparent)
                            }
                        }
                        bottomContent
                    }
                }
                .hFormObserveKeyboard
                .onAppear {
                    onAppear(with: proxy)
                }
            } else {
                hForm {
                    content(with: proxy)
                }
                .hFormAttachToBottom {
                    bottomContent
                }
                .hFormObserveKeyboard
                .onAppear {
                    onAppear(with: proxy)
                }
            }
        }
    }

    private func onAppear(with proxy: ScrollViewProxy) {
        selectedItems = items.filter({ preSelectedItems.contains($0.object) })
            .map({
                $0.object
            })
        if let selectedItem = selectedItems.first, selectedItems.count == 1 {
            proxy.scrollTo(selectedItem, anchor: .center)
        }

        if manualInput {
            proxy.scrollTo(manualInputId, anchor: .center)
        }
    }

    private func content(with proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 4) {
            ForEach(items, id: \.object) { item in
                hSection {
                    getCell(item: item.object)
                        .id(item.object)
                }
                .disabled(isLoading)
            }

            let showOtherCell = includeManualInput && !items.isEmpty
            let showFreeTextField = (manualInput && includeManualInput) || items.isEmpty

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
                        value: $manualBrandName,
                        equals: $type,
                        focusValue: .inputField,
                        placeholder: manualInputPlaceholder
                    )
                }
                .onAppear {
                    manualInput = true
                    selectedItems = []
                }
                .id(manualInputId)
            }
        }
    }

    var bottomContent: some View {
        hSection {
            VStack(spacing: 16) {
                bottomAttachedView

                hButton.LargeButton(type: .primary) {
                    sendSelectedItems
                } content: {
                    hText(hButtonText, style: .standard)
                }
                .hButtonIsLoading(isLoading)
                .disabled(disableIfNoneSelected ? selectedItems.isEmpty : false)
                if let onCancel {
                    hButton.LargeButton(type: .ghost) {
                        onCancel()
                    } content: {
                        hText(L10n.generalCancelButton, style: .standard)
                    }
                    .disabled(isLoading)
                    .hButtonDontShowLoadingWhenDisabled(true)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, 16)
    }

    var sendSelectedItems: Void {
        if selectedItems.count > 1 {
            onSelected(
                selectedItems.map({
                    (object: $0, displayName: nil)
                })
            )
        } else if selectedItems.count == 0 {
            if manualInput && includeManualInput {
                onSelected([(object: nil, displayName: manualBrandName)])
            } else {
                onSelected([])
            }
        } else {
            if let object = selectedItems.first {
                onSelected([(object: object, displayName: nil)])
            }
        }
    }

    @ViewBuilder
    func getCell(item: T? = nil, displayName: String? = nil) -> some View {
        if showDividers ?? false {
            hRow {
                displayContentFor(item, displayName)
            }
            .withEmptyAccessory
            .verticalPadding(fieldSize == .small ? 12.5 : 20.5)
            .onTap {
                if let item {
                    withAnimation {
                        manualInput = false
                    }
                    onTapExecuteFor(item)
                } else {
                    withAnimation {
                        manualInput = true
                    }
                    selectedItems = []
                    type = .inputField
                }
            }
        } else {
            hRow {
                displayContentFor(item, displayName)
            }
            .withEmptyAccessory
            .verticalPadding(fieldSize == .small ? 12.5 : 20.5)
            .onTap {
                if let item {
                    withAnimation {
                        manualInput = false
                    }
                    onTapExecuteFor(item)
                } else {
                    withAnimation {
                        manualInput = true
                        type = .inputField
                    }
                }
            }
            .hWithoutDivider
        }
    }

    @ViewBuilder
    func displayContentFor(_ item: T?, _ itemDisplayName: String?) -> some View {
        let isSelected = selectedItems.first(where: { $0 == item }) != nil || (manualInput && itemDisplayName != nil)
        let displayName = items.first(where: { $0.object == item })?.displayName

        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Group {
                    let titleFont: HFontTextStyle =
                        (displayName?.subTitle != nil || displayName?.extraSubTitle != nil) ? .body : .title3

                    hText(displayName?.title ?? itemDisplayName ?? "", style: titleFont)
                        .foregroundColor(hTextColor.primary)

                    if let subTitle = displayName?.subTitle {
                        hText(subTitle, style: .standardSmall)
                            .foregroundColor(hTextColor.secondaryTranslucent)
                    }

                    if let extraSubTitle = displayName?.extraSubTitle {
                        hText(extraSubTitle, style: .standardSmall)
                            .foregroundColor(hTextColor.secondaryTranslucent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            checkBox(isSelected: isSelected)
        }
    }

    func onTapExecuteFor(_ item: T) {
        ImpactGenerator.soft()
        withAnimation(.easeInOut(duration: 0)) {
            if !(singleSelect ?? true) {
                if let index = self.selectedItems.firstIndex(where: { $0 == item }) {
                    selectedItems.remove(at: index)
                } else {
                    selectedItems.append(item)
                }
            } else {
                if let firstItem = selectedItems.first {
                    if !(firstItem == item) {
                        selectedItems = [item]
                    }
                } else {
                    selectedItems = [item]
                }
            }
        }
    }

    func checkBox(isSelected: Bool) -> some View {
        Group {
            if singleSelect ?? false {
                ZStack {
                    Circle()
                        .strokeBorder(
                            RadioFieldsColors().getBorderColor(isSelected: isSelected),
                            lineWidth: isSelected ? 0 : 1.5
                        )
                        .background(Circle().foregroundColor(getFillColor(isSelected: isSelected)))

                    if isSelected && coloredCheckBox {
                        Circle()
                            .strokeBorder(
                                RadioFieldsColors().getBorderColor(isSelected: isSelected),
                                lineWidth: isSelected ? 0 : 1.5
                            )
                            .background(Circle().foregroundColor(hFillColor.opaqueOne))
                            .frame(height: 8)
                    }
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            RadioFieldsColors().getBorderColor(isSelected: isSelected),
                            lineWidth: isSelected ? 0 : 1.5
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(getFillColor(isSelected: isSelected))
                        )

                    if isSelected {
                        Image(uiImage: hCoreUIAssets.tick.image)
                            .foregroundColor(hTextColor.negative)
                    }
                }
            }
        }
        .frame(width: 24, height: 24)
    }

    @hColorBuilder
    func getFillColor(isSelected: Bool) -> some hColor {
        if isSelected {
            if coloredCheckBox {
                hSignalColor.greenElement
            } else {
                hTextColor.primary
            }
        } else {
            hFillColor.opaqueOne
        }
    }

    public struct CheckboxInfoCard {
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

struct CheckboxPickerScreen_Previews: PreviewProvider {

    struct ModelForPreview: Equatable, Hashable {
        let id: String
        let name: DisplayString
    }
    static var previews: some View {
        VStack {
            CheckboxPickerScreen<ModelForPreview>(
                items: {
                    return [
                        ModelForPreview(id: "id", name: .init(title: "name1")),
                        ModelForPreview(id: "id2", name: .init(title: "title2", subTitle: "subtitle2")),
                        ModelForPreview(
                            id: "id3",
                            name: .init(title: "title3", subTitle: "subtitle3", extraSubTitle: "extra subtitle")
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
                title: "title",
                titleMarker: "1/2"
            )
            .hIncludeManualInput
        }
    }
}

private struct EnvironmentHCheckboxPickerBottomAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hCheckboxPickerBottomAttachedView: AnyView? {
        get { self[EnvironmentHCheckboxPickerBottomAttachedView.self] }
        set { self[EnvironmentHCheckboxPickerBottomAttachedView.self] = newValue }
    }
}

extension View {
    public func hCheckboxPickerBottomAttachedView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hCheckboxPickerBottomAttachedView, AnyView(content()))
    }
}

enum CheckboxFieldType: hTextFieldFocusStateCompliant {
    static var last: CheckboxFieldType {
        return CheckboxFieldType.inputField
    }

    var next: CheckboxFieldType? {
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

private struct EnvironmentHUseColoredCheckbox: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hUseColoredCheckbox: Bool {
        get { self[EnvironmentHUseColoredCheckbox.self] }
        set { self[EnvironmentHUseColoredCheckbox.self] = newValue }
    }
}

extension View {
    public var hUseColoredCheckbox: some View {
        self.environment(\.hUseColoredCheckbox, true)
    }
}
