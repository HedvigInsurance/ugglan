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
                ChatTooltipView(
                    displayTooltip: $displayTooltip,
                    defaultsId: "chatHint",
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

    @ViewBuilder
    public func withOptionalChatButton(showChat: Bool, tooltip: Bool = false, action: @escaping () -> Void) -> some View
    {
        if showChat {
            ModifiedContent(content: self, modifier: ChatButtonModifier(tooltip: tooltip, action: action))
        } else {
            self
        }
    }
}
