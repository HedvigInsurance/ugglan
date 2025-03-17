import SwiftUI
import hCore

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
        if modally {
            ItemPickerScreen<T>(
                config: itemPickerConfig
            )
            .hFieldSize(.large)
            .hItemPickerAttributes([.singleSelect])
            .hFormContentPosition(.compact)
            .configureTitle(title)
        } else {
            ItemPickerScreen<T>(
                config: itemPickerConfig
            )
            .hFormTitle(
                title: .init(.small, .body2, title, alignment: .leading),
                subTitle: subtitle != nil ? .init(.small, .body2, subtitle ?? "") : nil
            )
            .hFieldSize(.medium)
            .hItemPickerAttributes([.singleSelect, .attachToBottom, .disableIfNoneSelected])
            .hFormContentPosition(.bottom)
            .withDismissButton()
        }
    }
}
