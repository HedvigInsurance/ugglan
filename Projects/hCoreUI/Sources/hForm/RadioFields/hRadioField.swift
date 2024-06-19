import Combine
import SwiftUI
import hCore

public struct hRadioField: View {
    private let leftView: AnyView?
    private let itemModel: ItemModel?
    private let id: String
    private var useAnimation: Bool
    @Environment(\.hFieldSize) var size
    @Binding var selected: String?
    @Binding private var error: String?
    @State private var animate = false

    public init(
        id: String,
        itemModel: ItemModel? = nil,
        leftView: (() -> AnyView)?,
        selected: Binding<String?>,
        error: Binding<String?>? = nil,
        useAnimation: Bool = false
    ) {
        self.id = id
        self.itemModel = itemModel
        self.leftView = leftView?()
        self._selected = selected
        self._error = error ?? Binding.constant(nil)
        self.useAnimation = useAnimation
    }

    public var body: some View {
        mainContent
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
        hFieldTextContent<EmptyView>(
            item: itemModel,
            fieldSize: size,
            itemDisplayName: nil,
            leftView: {
                leftView
            },
            cellView: {
                AnyView(
                    hRadioOptionSelectedView(
                        selectedValue: $selected,
                        value: id
                    )
                )
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
                            Image(uiImage: hCoreUIAssets.pillowHome.image)
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
            return 16
        }
    }

    fileprivate var bottomPadding: CGFloat {
        topPadding + 2
    }
}

extension View {
    public var asAnyView: AnyView {
        return AnyView(self)
    }
}
