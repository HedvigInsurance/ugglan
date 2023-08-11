import Foundation
import SwiftUI
import hCore

struct ChatButtonView: View {
    @State var displayTooltip = false
    var withTooltip: Bool = false
    var action: () -> Void

    init(
        withTooltip: Bool = false,
        action: @escaping () -> Void
    ) {
        self.withTooltip = withTooltip
        self.action = action
    }

    var tooltipView: some View {
        VStack {
            if withTooltip {
                TooltipView(
                    displayTooltip: $displayTooltip,
                    type: .chat,
                    timeInterval: .days(numberOfDays: 30)
                )
                .position(x: 37, y: 74)
                .fixedSize()
            }
        }
    }

    var body: some View {
        VStack {
            SwiftUI.Button(action: {
                withAnimation(.spring()) {
                    displayTooltip = false
                }
                action()
            }) {
                Image(uiImage: hCoreUIAssets.chatQuickNav.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 1)
            }
            .animation(nil)
        }
        .background(tooltipView)
    }
}

struct ChatButtonModifier: ViewModifier {
    let tooltip: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationBarItems(
                trailing:
                    ChatButtonView(withTooltip: tooltip) {
                        action()
                    }
            )
    }
}

extension hForm {
    public func withChatButton(tooltip: Bool = false, action: @escaping () -> Void) -> some View {
        ModifiedContent(content: self, modifier: ChatButtonModifier(tooltip: tooltip, action: action))
    }

    public func setHomeNavigationBars(
        with options: Binding<[ToolbarOptionType]>,
        action: @escaping (_: ToolbarOptionType) -> Void
    ) -> some View {
        ModifiedContent(content: self, modifier: ToolbarButtonsViewModifier(action: action, types: options))
    }
}

public enum ToolbarOptionType: String, Codable {
    case newOffer
    case firstVet
    case chat

    var image: UIImage {
        switch self {
        case .newOffer:
            return hCoreUIAssets.campaignQuickNav.image
        case .firstVet:
            return hCoreUIAssets.firstVetQuickNav.image
        case .chat:
            return hCoreUIAssets.chatQuickNav.image
        }
    }

    var tooltipId: String {
        switch self {
        case .newOffer:
            return "newOfferHint"
        case .firstVet:
            return "firstVettHint"
        case .chat:
            return "chatHint"
        }
    }
}

struct ToolbarButtonsView: View {
    @State var displayTooltip = false
    var action: ((_: ToolbarOptionType)) -> Void
    @Binding var types: [ToolbarOptionType]

    init(
        types: Binding<[ToolbarOptionType]>,
        action: @escaping (_: ToolbarOptionType) -> Void
    ) {
        self._types = types
        self.action = action
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(types.enumerated()), id: \.element.rawValue) { index, type in
                VStack {
                    SwiftUI.Button(action: {
                        withAnimation(.spring()) {
                            displayTooltip = false
                        }
                        action(type)
                    }) {
                        Image(uiImage: type.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 1)
                    }
                    .animation(nil)
                }
                .background(
                    VStack {
                        if type == .chat {
                            TooltipView(
                                displayTooltip: $displayTooltip,
                                type: type,
                                timeInterval: .days(numberOfDays: 30)
                            )
                            .position(x: 37, y: 74)
                            .fixedSize()
                        }
                    }
                )
            }
        }
    }
}

struct ToolbarButtonsViewModifier: ViewModifier {
    let action: (_: ToolbarOptionType) -> Void
    @Binding var types: [ToolbarOptionType]
    func body(content: Content) -> some View {
        content
            .navigationBarItems(
                trailing:
                    ToolbarButtonsView(types: $types, action: action)
            )
    }
}
