import SwiftUI
import hCore
import hCoreUI

public struct ListScreen<T>: View {
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
            ListItems(
                onClick: { item in
                    onSelected(item)
                },
                items: items
            )
            .hListRowStyle(.filled)
        }
        .hFormContentPosition(.bottom)
        .hFormAlwaysAttachToBottom {
            hSection {
                hCancelButton {
                    onCancel()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

struct ItemPickerScreen_Previews: PreviewProvider {
    struct ModelForPreview {
        let id: String
        let name: String
    }

    static var previews: some View {
        ListScreen<ModelForPreview>(
            items: {
                let items = [
                    ModelForPreview(id: "id", name: "name"),
                    ModelForPreview(id: "id2", name: "name2"),
                ]

                return items.compactMap { (object: $0, displayName: $0.name) }
            }(),
            onSelected: { _ in
            },
            onCancel: {}
        )
    }
}
