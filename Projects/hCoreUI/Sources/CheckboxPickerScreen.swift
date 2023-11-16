import SwiftUI
import hCore

public struct CheckboxPickerScreen<T>: View where T: Equatable & Hashable {
    typealias PickerModel = (object: T, displayName: String)
    var items: [PickerModel]
    let preSelectedItems: [T]
    let onSelected: ([T]) -> Void
    let onCancel: (() -> Void)?
    let singleSelect: Bool?
    let showDividers: Bool?
    let attachToBottom: Bool
    @State var selectedItems: [T] = []
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hCheckboxPickerBottomAttachedView) var bottomAttachedView

    public init(
        items: [(object: T, displayName: String)],
        preSelectedItems: @escaping () -> [T],
        onSelected: @escaping ([T]) -> Void,
        onCancel: (() -> Void)? = nil,
        singleSelect: Bool? = false,
        showDividers: Bool? = false,
        attachToBottom: Bool = false
    ) {
        self.items = items
        self.preSelectedItems = preSelectedItems()
        self.onSelected = onSelected
        self.onCancel = onCancel
        self.singleSelect = singleSelect
        self.showDividers = showDividers
        self.attachToBottom = attachToBottom
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
                    selectedItems = items.filter({ preSelectedItems.contains($0.object) }).map({ $0.object })
                }
        } else {
            hForm {
                content
            }
            .hFormAttachToBottom {
                bottomContent
            }
            .onAppear {
                selectedItems = items.filter({ preSelectedItems.contains($0.object) }).map({ $0.object })
            }
        }
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 4) {
            ForEach(items, id: \.object) { item in
                hSection {
                    getCell(item: item)
                }
                .disabled(isLoading)
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
                    hText(L10n.generalContinueButton, style: .standard)
                }
                .hButtonIsLoading(isLoading)
                if let onCancel {
                    hButton.LargeButton(type: .ghost) {
                        onCancel()
                    } content: {
                        hText(L10n.generalCancelButton, style: .standard)
                    }
                    .disabled(isLoading)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, 16)
    }

    var sendSelectedItems: Void {
        if selectedItems.count > 1 {
            onSelected(selectedItems.map({ $0 }))
        } else {
            if let object = selectedItems.first {
                onSelected([object])
            }
        }
    }

    @ViewBuilder
    func getCell(item: (object: T, displayName: String)) -> some View {
        if showDividers ?? false {
            hRow {
                displayContentFor(item.object)
            }
            .withEmptyAccessory
            .verticalPadding(9)
            .onTap {
                onTapExecuteFor(item.object)
            }
            .hWithoutDivider
        } else {
            hRow {
                displayContentFor(item.object)
            }
            .withEmptyAccessory
            .onTap {
                onTapExecuteFor(item.object)
            }
        }
    }

    @ViewBuilder
    func displayContentFor(_ item: T) -> some View {
        let isSelected = selectedItems.first(where: { $0 == item }) != nil
        let displayName = items.first(where: { $0.object == item })?.displayName ?? ""
        HStack(spacing: 0) {
            hText(displayName, style: .title3)
                .foregroundColor(hTextColor.primary)
            Spacer()
            Circle()
                .strokeBorder(
                    getBorderColor(isSelected: isSelected),
                    lineWidth: isSelected ? 0 : 1.5
                )
                .background(Circle().foregroundColor(retColor(isSelected: isSelected)))
                .frame(width: 28, height: 28)
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
                if !(selectedItems.first == item) {
                    selectedItems = [item]
                }
            }
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.primary
        } else {
            hFillColor.opaqueOne
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.primary
        } else {
            hBorderColor.opaqueTwo
        }
    }
}
struct CheckboxPickerScreen_Previews: PreviewProvider {

    struct ModelForPreview: Equatable, Hashable {
        let id: String
        let name: String
    }
    static var previews: some View {
        CheckboxPickerScreen<ModelForPreview>(
            items: {
                return [
                    ModelForPreview(id: "id", name: "name"),
                    ModelForPreview(id: "id2", name: "name2"),
                ]
                .compactMap({ (object: $0, displayName: $0.name) })
            }(),
            preSelectedItems: { [] },
            onSelected: { selectedLocation in

            },
            onCancel: {

            },
            singleSelect: true
        )
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
