import Combine
import SwiftUI
import hCore

public struct hRadioField<Content: View>: View {
    private let customContent: Content?
    private let itemModel: ItemModel?

    private let id: String
    private var useAnimation: Bool
    @Environment(\.hFieldSize) var size
    @Environment(\.hFieldLeftAttachedView) var leftAligned
    @Environment(\.isEnabled) var enabled
    @Binding var selected: String?
    @Binding private var error: String?
    @State private var animate = false
    let leftView: (() -> AnyView?)?

    public init(
        id: String,
        itemModel: ItemModel? = nil,
        customContent: (() -> Content)?,
        selected: Binding<String?>,
        error: Binding<String?>? = nil,
        useAnimation: Bool = false,
        leftView: (() -> AnyView?)? = nil
    ) {
        self.id = id
        self.itemModel = itemModel
        self.customContent = customContent?()
        self._selected = selected
        self._error = error ?? Binding.constant(nil)
        self.useAnimation = useAnimation
        self.leftView = leftView
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let leftView = leftView?() {
                leftView
            }
            if leftAligned {
                hRadioOptionSelectedView(selectedValue: $selected, value: id)
                mainContent
                Spacer()
            } else {
                mainContent
                Spacer()
                hRadioOptionSelectedView(selectedValue: $selected, value: id)
            }
        }
        .padding(.top, size.topPadding)
        .padding(.bottom, size.bottomPadding)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            ImpactGenerator.soft()
            withAnimation(.none) {
                self.selected = id
            }
            if useAnimation {
                self.animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.animate = false
                }
            }
        }
    }

    @ViewBuilder
    var mainContent: some View {
        if let customContent {
            customContent
        } else if let itemModel {
            hFieldTextContent(
                item: itemModel,
                fieldSize: size,
                itemDisplayName: nil
            )
        }
    }
}

struct hRadioField_Previews: PreviewProvider {
    @State static var value: String?
    @State static var error: String?
    static var previews: some View {
        hSection {
            VStack {
                hRadioField(
                    id: "id",
                    customContent: {
                        hText("id")
                    },
                    selected: $value,
                    error: $error,
                    useAnimation: true,
                    leftView: {
                        AnyView {
                            VStack {
                                hText("Label")
                                hText("920321412")
                            }
                        }
                    }
                )
                .hFieldSize(.large)

                hRadioField<EmptyView>(
                    id: "id",
                    itemModel: .init(
                        title: "Large Label"
                    ),
                    customContent: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)

                hRadioField<EmptyView>(
                    id: "id",
                    itemModel: .init(
                        title: "Large Label",
                        subTitle: "920321412"
                    ),
                    customContent: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)

                hRadioField<EmptyView>(
                    id: "id",
                    itemModel: .init(
                        title: "Medium field Label",
                        subTitle: "920321412"
                    ),
                    customContent: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.medium)

                hRadioField<EmptyView>(
                    id: "id",
                    itemModel: .init(
                        title: "Small field Label",
                        subTitle: "920321412"
                    ),
                    customContent: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.small)

                hRadioField(
                    id: "id",
                    customContent: {
                        AnyView(
                            HStack {
                                Image(uiImage: hCoreUIAssets.pillowHome.image)
                                    .resizable()
                                    .frame(width: 32, height: 32)

                                hText("Label")
                            }
                        )
                    },
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.small)

                hRadioField<EmptyView>(
                    id: "id",
                    itemModel: .init(
                        title: "Label",
                        subTitle: "920321412"
                    ),
                    customContent: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)
                .hFieldLeftAttachedView

                hRadioField<EmptyView>(
                    id: "id",
                    itemModel: .init(
                        title: "Label"
                    ),
                    customContent: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)
                .hFieldLeftAttachedView
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

extension hFieldSize {
    fileprivate var minHeight: CGFloat {
        switch self {
        case .small:
            return 56
        case .large:
            return 64
        case .medium:
            return 64
        }
    }

    fileprivate var topPadding: CGFloat {
        switch self {
        case .small:
            return 15
        case .large:
            return 16
        case .medium:
            return 19
        }
    }

    fileprivate var bottomPadding: CGFloat {
        topPadding + 2
    }
}
