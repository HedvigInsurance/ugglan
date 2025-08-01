import Combine
import hCore
import SwiftUI

public struct hRadioField<T>: View where T: Equatable {
    private let leftView: AnyView?
    private let itemModel: ItemModel?
    private let id: T
    private var useAnimation: Bool
    @Environment(\.hFieldSize) var size
    @Binding var selected: T?
    @Binding private var error: String?
    @State private var animate = false

    public init(
        id: T,
        itemModel: ItemModel? = nil,
        leftView: (() -> AnyView)?,
        selected: Binding<T?>,
        error: Binding<String?>? = nil,
        useAnimation: Bool = false
    ) {
        self.id = id
        self.itemModel = itemModel
        self.leftView = leftView?()
        _selected = selected
        _error = error ?? Binding.constant(nil)
        self.useAnimation = useAnimation
    }

    public var body: some View {
        mainContent
            .padding(.top, size.topPadding)
            .padding(.bottom, size.bottomPadding)
            .addFieldBackground(animate: $animate, error: $error)
            .addFieldError(animate: $animate, error: $error)
            .accessibilityElement(children: .combine)
            .onTapGesture {
                ImpactGenerator.soft()
                withAnimation(.none) {
                    selected = id
                }
                if useAnimation {
                    animate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animate = false
                    }
                }
            }
    }

    @ViewBuilder
    var mainContent: some View {
        hFieldTextContent<EmptyView>(
            item: itemModel,
            fieldSize: size,
            itemDisplayName: nil,
            leftView: {
                leftView
            },
            cellView: {
                hRadioOptionSelectedView(
                    selectedValue: $selected,
                    value: id
                )
                .asAnyView
            }
        )
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
                    leftView: {
                        VStack(alignment: .leading) {
                            hText("Label left view")
                            hText("920321412")
                        }
                        .asAnyView
                    },
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)

                hRadioField(
                    id: "id",
                    itemModel: .init(
                        title: "Large Label"
                    ),
                    leftView: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)

                hRadioField(
                    id: "id",
                    itemModel: .init(
                        title: "Large Label",
                        subTitle: "920321412"
                    ),
                    leftView: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)

                hRadioField(
                    id: "id",
                    itemModel: .init(
                        title: "Medium field Label",
                        subTitle: "920321412"
                    ),
                    leftView: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.medium)

                hRadioField(
                    id: "id",
                    itemModel: .init(
                        title: "Small field Label",
                        subTitle: "920321412"
                    ),
                    leftView: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.small)

                hRadioField(
                    id: "id",
                    leftView: {
                        HStack {
                            hCoreUIAssets.pillowHome.view
                                .resizable()
                                .frame(width: 32, height: 32)

                            hText("Custom view with long text")
                        }
                        .asAnyView
                    },
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.small)

                hRadioField(
                    id: "id",
                    itemModel: .init(
                        title: "Label",
                        subTitle: "920321412"
                    ),
                    leftView: nil,
                    selected: $value,
                    error: $error,
                    useAnimation: true
                )
                .hFieldSize(.large)
                .hFieldLeftAttachedView

                hRadioField(
                    id: "id",
                    itemModel: .init(
                        title: "Label"
                    ),
                    leftView: nil,
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
    var minHeight: CGFloat {
        switch self {
        case .small:
            return 56
        case .large:
            return 64
        case .medium:
            return 64
        }
    }

    var topPadding: CGFloat {
        switch self {
        case .small:
            return 15
        case .large:
            return 16
        case .medium:
            return 19
        }
    }

    var topPaddingWithSubtitle: CGFloat {
        switch self {
        case .small:
            return 8.5
        case .large:
            return 10
        case .medium:
            return 11.5
        }
    }

    var bottomPadding: CGFloat {
        topPadding + 2
    }

    var bottomPaddingWithSubtitle: CGFloat {
        switch self {
        case .small:
            return 7.5
        case .large:
            return 9
        case .medium:
            return 12.5
        }
    }

    var topOffset: CGFloat {
        switch self {
        case .small: return 17
        case .medium: return 21
        case .large: return 18
        }
    }

    var bottomOffset: CGFloat {
        switch self {
        case .small: return 17
        case .medium: return 21
        case .large: return 18
        }
    }
}

public extension View {
    var asAnyView: AnyView {
        AnyView(self)
    }
}
