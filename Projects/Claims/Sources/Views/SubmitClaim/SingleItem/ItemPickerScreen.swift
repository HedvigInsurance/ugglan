import SwiftUI
import hCore
import hCoreUI

public struct ItemPickerScreen<T>: View {
    var items: [(object: T, displayName: String)]
    let onSelected: (T) -> Void
    public init(
        items: [(object: T, displayName: String)],
        onSelected: @escaping (T) -> Void
    ) {
        self.items = items
        self.onSelected = onSelected
    }

    public var body: some View {
        hForm {
            ForEach(items, id: \.displayName) { item in
                hSection {
                    hRow {
                        hTextNew(item.displayName, style: .body)
                            .foregroundColor(hLabelColorNew.primary)
                    }
                    .onTap {
                        onSelected(item.object)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hUseNewStyle
    }
}
