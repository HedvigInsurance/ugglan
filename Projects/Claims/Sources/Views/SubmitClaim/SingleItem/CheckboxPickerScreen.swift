import SwiftUI
import hCore
import hCoreUI

struct CheckboxPickerScreen<T>: View {
    typealias PickerModel = (object: T, displayName: String)
    var items: [PickerModel]
    let preSelectedItems: [String]
    let onSelected: ([T]) -> Void
    let onCancel: () -> Void
    let singleSelect: Bool?
    let showDividers: Bool?
    @State var selectedItems: [PickerModel] = []

    public init(
        items: [(object: T, displayName: String)],
        preSelectedItems: @escaping () -> [String],
        onSelected: @escaping ([T]) -> Void,
        onCancel: @escaping () -> Void,
        singleSelect: Bool? = false,
        showDividers: Bool? = false
    ) {
        self.items = items
        self.preSelectedItems = preSelectedItems()
        self.onSelected = onSelected
        self.onCancel = onCancel
        self.singleSelect = singleSelect
        self.showDividers = showDividers
    }

    var body: some View {
        hForm {
            ForEach(items, id: \.displayName) { item in
                hSection {
                    getCell(item: item)
                }
                .padding(.bottom, -4)
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButtonPrimary {
                    if selectedItems.count > 1 {
                        onSelected(selectedItems.map({ $0.object }))
                    } else {
                        if let object = selectedItems.first?.object {
                            onSelected([object])
                        }
                    }
                } content: {
                    hText(L10n.generalSaveButton, style: .body)
                }
                hButton.LargeButtonText {
                    onCancel()
                } content: {
                    hText(L10n.generalCancelButton, style: .body)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .onAppear {
            selectedItems = items.filter({ preSelectedItems.contains($0.displayName) })
        }
    }

    @ViewBuilder
    func getCell(item: (object: T, displayName: String)) -> some View {
        if showDividers ?? false {
            hRow {
                displayContent(displayName: item.displayName)
            }
            .withEmptyAccessory
            .verticalPadding(9)
            .onTap {
                onTapExecute(item: item)
            }
            .hWithoutDivider
        } else {

            hRow {
                displayContent(displayName: item.displayName)
            }
            .withEmptyAccessory
            .onTap {
                onTapExecute(item: item)
            }
        }
    }

    @ViewBuilder
    func displayContent(displayName: String) -> some View {
        let isSelected = selectedItems.first(where: { $0.displayName == displayName }) != nil
        HStack(spacing: 0) {
            hText(displayName, style: .title3)
                .foregroundColor(hTextColorNew.primary)
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

    func onTapExecute(item: (object: T, displayName: String)) {
        ImpactGenerator.soft()
        withAnimation(.easeInOut(duration: 0)) {
            if !(singleSelect ?? true) {
                if let index = self.selectedItems.firstIndex(where: { $0.displayName == item.displayName }) {
                    selectedItems.remove(at: index)
                } else {
                    selectedItems.append(item)
                }
            } else {
                if !(selectedItems.first?.displayName == item.displayName) {
                    selectedItems = [item]
                }
            }
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hFillColorNew.opaqueOne
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hBorderColorNew.opaqueTwo
        }
    }
}
struct CheckboxPickerScreen_Previews: PreviewProvider {

    struct ModelForPreview {
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
