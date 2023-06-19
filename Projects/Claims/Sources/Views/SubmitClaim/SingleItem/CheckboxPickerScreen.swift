import SwiftUI
import hCore
import hCoreUI

struct CheckboxPickerScreen<T>: View {
    var items: [(object: T, displayName: String)]
    let preSelectedItems: () -> [T]?
    let onSelected: ([T]) -> Void
    let onCancel: () -> Void
    let oneValueLimit: Bool?
    let smallerPadding: Bool?
    @State var selectedItems: [(object: T, displayName: String)] = []

    public init(
        items: [(object: T, displayName: String)],
        preSelectedItems: @escaping () -> [T]?,
        onSelected: @escaping ([T]) -> Void,
        onCancel: @escaping () -> Void,
        oneValueLimit: Bool? = false,
        smallerPadding: Bool? = false
    ) {
        self.items = items
        self.preSelectedItems = preSelectedItems
        self.onSelected = onSelected
        self.onCancel = onCancel
        self.oneValueLimit = oneValueLimit
        self.smallerPadding = smallerPadding
    }

    var body: some View {
        hForm {
            ForEach(items, id: \.displayName) { item in
                hSection {
                    showSmallerPadding(item: item)
                    showNormalPadding(item: item)
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

    @ViewBuilder
    func showSmallerPadding(item: (object: T, displayName: String)) -> some View {
        if smallerPadding ?? false {
            hRow {
                displayContent(displayName: item.displayName)
            }
            .withEmptyAccessory
            .verticalPadding(9)
            .onTap {
                onTapExecute(item: item)
            }
            .hWithoutDivider
        }
    }

    @ViewBuilder
    func showNormalPadding(item: (object: T, displayName: String)) -> some View {
        if !(smallerPadding ?? false) {
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
        hTextNew(displayName, style: .title3)
            .foregroundColor(hLabelColorNew.primary)
        Spacer()
        Circle()
            .strokeBorder(hBackgroundColorNew.semanticBorderTwo)
            .background(Circle().foregroundColor(retColor(currentItem: displayName)))
            .frame(width: 28, height: 28)
    }

    func onTapExecute(item: (object: T, displayName: String)) {
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
