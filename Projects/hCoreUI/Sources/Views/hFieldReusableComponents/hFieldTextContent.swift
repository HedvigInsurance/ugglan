import SwiftUI

public struct ItemModel: Hashable {
    let title: String
    let subTitle: String?

    public init(
        title: String,
        subTitle: String? = nil
    ) {
        self.title = title
        self.subTitle = subTitle
    }
}

public struct hFieldTextContent<T>: View {
    @Environment(\.isEnabled) var enabled
    @Environment(\.hFieldLeftAttachedView) var leftAlign
    @Environment(\.hFieldBottomAttachedView) var bottomView

    let item: ItemModel?
    let fieldSize: hFieldSize
    let itemDisplayName: String?
    let leftViewWithItem: ((T?) -> AnyView?)?
    let leftView: (() -> AnyView?)?
    let cellView: (() -> AnyView?)?

    public init(
        item: ItemModel? = nil,
        fieldSize: hFieldSize,
        itemDisplayName: String? = nil,
        leftViewWithItem: ((T?) -> AnyView?)? = nil,
        leftView: (() -> AnyView?)? = nil,
        cellView: (() -> AnyView?)?
    ) {
        self.item = item
        self.fieldSize = fieldSize
        self.itemDisplayName = itemDisplayName
        self.leftViewWithItem = leftViewWithItem
        self.leftView = leftView
        self.cellView = cellView
    }

    public var body: some View {
        HStack(spacing: .padding8) {
            if leftAlign {
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        cellView?()
                            .frame(alignment: .top)
                            .padding(.top, 2)
                        getTextField
                    }
                    if let bottomView {
                        bottomView
                    }
                }
            } else {
                getTextField
                Spacer()
                cellView?()
            }
        }
    }

    var getTextField: some View {
        HStack(spacing: .padding8) {
            if let leftViewWithItem = leftViewWithItem?(item as? T) {
                leftViewWithItem
            } else if let leftView = leftView?() {
                leftView
            } else {
                VStack(spacing: 0) {
                    Group {
                        let titleFont: HFontTextStyle =
                            (fieldSize != .large) ? .body1 : .heading2

                        hText(item?.title ?? itemDisplayName ?? "", style: titleFont)
                            .foregroundColor(getTitleColor)

                        if let subTitle = item?.subTitle {
                            hText(subTitle, style: .label)
                                .foregroundColor(getSubTitleColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    @hColorBuilder
    var getTitleColor: some hColor {
        if !enabled {
            hTextColor.Translucent.disabled
        } else {
            hTextColor.Opaque.primary
        }
    }

    @hColorBuilder
    var getSubTitleColor: some hColor {
        if !enabled {
            hTextColor.Translucent.disabled
        } else {
            hTextColor.Translucent.secondary
        }
    }
}

@MainActor
private struct EnvironmentHFieldBottomAttachedView: @preconcurrency EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

public extension EnvironmentValues {
    var hFieldBottomAttachedView: AnyView? {
        get { self[EnvironmentHFieldBottomAttachedView.self] }
        set { self[EnvironmentHFieldBottomAttachedView.self] = newValue }
    }
}

public extension View {
    func hFieldAttachToBottom<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        environment(\.hFieldBottomAttachedView, AnyView(content()))
    }
}
