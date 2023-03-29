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
            hSection {
                ForEach(items, id: \.displayName) { item in
                    hRow {
                        hText(item.displayName, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .onTap {
                        onSelected(item.object)
                    }
                }
            }
        }
    }
}
