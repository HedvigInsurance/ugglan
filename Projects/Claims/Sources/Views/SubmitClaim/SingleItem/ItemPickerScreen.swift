import SwiftUI
import hCore
import hCoreUI

public struct ItemPickerScreen<T>: View {
    var items: [(object: T, displayName: String)]
    let onSelected: (T) -> Void
    let onCancel: () -> Void
    public init(
        items: [(object: T, displayName: String)],
        onSelected: @escaping (T) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.items = items
        self.onSelected = onSelected
        self.onCancel = onCancel
    }

    public var body: some View {
        hForm {
            ForEach(items, id: \.displayName) { item in
                hSection {
                    hRow {
                        hTextNew(item.displayName, style: .title3)
                            .foregroundColor(hLabelColorNew.primary)
                    }
                    .withChevronAccessory
                    .verticalPadding(9)
                    .onTap {
                        onSelected(item.object)
                    }
                    .foregroundColor(hLabelColorNew.tertiary)
                }
            }
        }
        .hUseNewStyle
        .hFormAttachToBottom {
            hButton.LargeButtonText {
                onCancel()
            } content: {
                hTextNew(L10n.generalCancelButton, style: .body)
            }
            .padding(.horizontal, 16)
        }
    }
}
