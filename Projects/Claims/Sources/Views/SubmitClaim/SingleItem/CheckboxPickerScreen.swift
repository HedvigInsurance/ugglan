import SwiftUI
import hCore
import hCoreUI

struct CheckboxPickerScreen<T>: View {
    var items: [(object: T, displayName: String)]
    let preSelectedItems: () -> [T]?
    let onSelected: ([T]) -> Void
    let onCancel: () -> Void
    let oneValueLimit: Bool?
    @State var selectedItems: [(object: T, displayName: String)] = []

    public init(
        items: [(object: T, displayName: String)],
        preSelectedItems: @escaping () -> [T]?,
        onSelected: @escaping ([T]) -> Void,
        onCancel: @escaping () -> Void,
        oneValueLimit: Bool? = false
    ) {
        self.items = items
        self.preSelectedItems = preSelectedItems
        self.onSelected = onSelected
        self.onCancel = onCancel
        self.oneValueLimit = oneValueLimit
    }

    var body: some View {
        hForm {
            ForEach(items, id: \.displayName) { item in
                hSection {
                    hRow {
                        hTextNew(item.displayName, style: .title3)
                            .foregroundColor(hLabelColorNew.primary)
                        Spacer()
                        Circle()
                            .strokeBorder(hBackgroundColorNew.semanticBorderTwo)
                            .background(Circle().foregroundColor(retColor(currentItem: item.displayName)))
                            .frame(width: 28, height: 28)
                    }
                    .withEmptyAccessory
                    .onTap {
                        if !(oneValueLimit ?? true) {
                            var remove = false
                            var index = 0
                            for selectedItem in selectedItems {
                                if selectedItem.displayName == item.displayName {
                                    remove = true
                                    break
                                }
                                if !remove {
                                    index += 1
                                }
                            }
                            if remove {
                                selectedItems.remove(at: index)
                            } else {
                                selectedItems.append(item)
                            }
                        } else {
                            if !(selectedItems.first?.displayName == item.displayName) {
                                selectedItems = []
                                selectedItems.append(item)
                            }
                        }
                    }
                }
            }
        }
        .hUseNewStyle
        .hFormAttachToBottom {
            VStack(spacing: 0) {
                hButton.LargeButtonFilled {
                    if selectedItems.count > 1 {
                        var itemArr: [T] = []
                        for item in selectedItems {
                            itemArr.append(item.object)
                        }
                        onSelected(itemArr)
                    } else {
                        if let object = selectedItems.first?.object {
                            onSelected([object])
                        }
                    }
                } content: {
                    hText(L10n.generalContinueButton)
                }
                hButton.LargeButtonText {
                    onCancel()
                } content: {
                    hTextNew(L10n.generalCancelButton, style: .body)
                }
            }
            .padding([.leading, .trailing], 16)
        }
        .onAppear {
            preSelectedItems()?
                .forEach { item in
                    self.selectedItems.append((item, ""))
                }
        }
    }

    func checkIfItemInSelected(currentItem: String) -> Bool {
        var containsElement = false
        selectedItems.forEach { x in
            if x.displayName == currentItem {
                containsElement = true
            }
        }
        return containsElement
    }

    @hColorBuilder
    func retColor(currentItem: String) -> some hColor {
        if selectedItems.count > 1 {
            if checkIfItemInSelected(currentItem: currentItem) {
                hLabelColorNew.primary
            } else {
                hBackgroundColorNew.opaqueOne
            }

        } else {
            if selectedItems.first?.displayName == currentItem {
                hLabelColorNew.primary
            } else {
                hBackgroundColorNew.opaqueOne
            }
        }
    }
}
