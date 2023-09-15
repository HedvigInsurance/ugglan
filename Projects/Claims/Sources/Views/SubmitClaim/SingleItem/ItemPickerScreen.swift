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
            VStack(spacing: 4) {
                ForEach(items, id: \.displayName) { item in
                    hSection {
                        hRow {
                            hText(item.displayName, style: .title3)
                                .foregroundColor(hTextColorNew.primary)
                        }
                        .withChevronAccessory
                        .verticalPadding(9)
                        .onTap {
                            onSelected(item.object)
                        }
                        .foregroundColor(hTextColorNew.tertiary)
                    }
                }
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
                onCancel()
            } content: {
                hText(L10n.generalCancelButton, style: .body)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}

struct ItemPickerScreen_Previews: PreviewProvider {

    struct ModelForPreview {
        let id: String
        let name: String
    }
    static var previews: some View {
        ItemPickerScreen<ModelForPreview>(
            items: {
                let items = [
                    ModelForPreview(id: "id", name: "name"),
                    ModelForPreview(id: "id2", name: "name2"),
                ]

                return items.compactMap({ (object: $0, displayName: $0.name) })
            }(),
            onSelected: { item in

            },
            onCancel: {
            }
        )

    }
}
