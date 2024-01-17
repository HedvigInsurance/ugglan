import SwiftUI
import hCore

public struct CheckboxPickerScreen<T>: View where T: Equatable & Hashable {
    typealias PickerModel = (object: T, displayName: String)
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

    @State var type: CheckboxFieldType? = .inputField

    @State private var selectedItems: [T] = []
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hCheckboxPickerBottomAttachedView) var bottomAttachedView
    @Environment(\.hIncludeManualInput) var includeManualInput

    @State var manualBrandName: String = ""
    @State var manualInput: Bool = false

    private var fieldSize: hFieldSize

    public init(
        items: [(object: T, displayName: String)],
        preSelectedItems: @escaping () -> [T],
        onSelected: @escaping ([(T?, String?)]) -> Void,
        onCancel: (() -> Void)? = nil,
        singleSelect: Bool? = false,
        showDividers: Bool? = false,
        attachToBottom: Bool = false,
        disableIfNoneSelected: Bool = false,
        manualInputPlaceholder: String? = "",
        hButtonText: String? = L10n.generalSaveButton
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
        self.hButtonText = hButtonText ?? L10n.generalSaveButton
        if items.count > 3 {
            self.fieldSize = .small
        } else {
            self.fieldSize = .large
        }
    }

    public var body: some View {
        if attachToBottom {
            hForm {}
                .hFormAttachToBottom {
                    VStack(spacing: 0) {
                        content
                        bottomContent
                    }
                }
                .onAppear {
                    selectedItems = items.filter({ preSelectedItems.contains($0.object) })
                        .map({
                            $0.object
                        })
                }
        } else {
            hForm {
                content
            }
            .hFormAttachToBottom {
                bottomContent
            }
            .onAppear {
                selectedItems = items.filter({ preSelectedItems.contains($0.object) })
                    .map({
                        $0.object
                    })
            }
        }
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 4) {
            ForEach(items, id: \.object) { item in
                hSection {
                    getCell(item: item.object)
                }
                .disabled(isLoading)
            }
            if includeManualInput {
                hSection {
                    getCell(displayName: L10n.manualInputListOther)
                }
                .disabled(isLoading)
            }

            if manualInput && includeManualInput {
                hSection {
                    hFloatingTextField(
                        masking: Masking(type: .none),
                        value: $manualBrandName,
                        equals: $type,
                        focusValue: .none,
                        placeholder: manualInputPlaceholder
                    )
                }
            }
        }
    }

    var bottomContent: some View {
        hSection {
            VStack(spacing: 8) {
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
            onSelected([(object: nil, displayName: manualBrandName)])
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
                    manualInput = false
                    onTapExecuteFor(item)
                } else {
                    manualInput = true
                    selectedItems = []
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
                    manualInput = false
                    onTapExecuteFor(item)
                } else {
                    manualInput = true

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
            hText(displayName ?? itemDisplayName ?? "", style: .title3)
                .foregroundColor(hTextColor.primary)
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
                Circle()
                    .strokeBorder(
                        RadioFieldsColors().getBorderColor(isSelected: isSelected),
                        lineWidth: isSelected ? 0 : 1.5
                    )
                    .background(Circle().foregroundColor(retColor(isSelected: isSelected)))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            RadioFieldsColors().getBorderColor(isSelected: isSelected),
                            lineWidth: isSelected ? 0 : 1.5
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(retColor(isSelected: isSelected))
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
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.primary
        } else {
            hFillColor.opaqueOne
        }
    }
}

struct CheckboxPickerScreen_Previews: PreviewProvider {

    struct ModelForPreview: Equatable, Hashable {
        let id: String
        let name: String
    }
    static var previews: some View {
        VStack {
            CheckboxPickerScreen<ModelForPreview>(
                items: {
                    return [
                        ModelForPreview(id: "id", name: "name"),
                        ModelForPreview(id: "id2", name: "name2"),
                        ModelForPreview(id: "id3", name: "name3"),
                        ModelForPreview(id: "id4", name: "name4"),
                    ]
                    .compactMap({ (object: $0, displayName: $0.name) })
                }(),
                preSelectedItems: { [] },
                onSelected: { selectedLocation in

                },
                onCancel: {
                },
                singleSelect: true,
                manualInputPlaceholder: "Enter brand name"
            )
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
