import SwiftUI

public struct ContractSelectView<T: Hashable>: View {
    let itemPickerConfig: ItemConfig<T>
    let title: String
    let subtitle: String?
    let modally: Bool

    public init(
        itemPickerConfig: ItemConfig<T>,
        title: String,
        subtitle: String?,
        modally: Bool? = false
    ) {
        self.itemPickerConfig = itemPickerConfig
        self.title = title
        self.subtitle = subtitle
        self.modally = modally ?? false
    }

    public var body: some View {
        Group {
            if modally {
                ItemPickerScreen<T>(
                    config: itemPickerConfig
                )
                .hItemPickerAttributes([.singleSelect])
                .hFormContentPosition(.compact)
                .navigationTitle(title)
            } else {
                ItemPickerScreen<T>(
                    config: itemPickerConfig
                )
                .hFormTitle(
                    title: .init(.small, .body2, title, alignment: .leading),
                    subTitle: subtitle != nil ? .init(.small, .body2, subtitle ?? "") : nil
                )
                .hItemPickerAttributes([.singleSelect, .attachToBottom, .disableIfNoneSelected])
                .hFormContentPosition(.bottom)
                .withDismissButton()
            }
        }
        .hFieldSize(.medium)
    }
}
