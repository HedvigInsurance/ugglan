import Apollo
import Chat
import Flow
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    @JourneyBuilder
    static func freeTextChat(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        ChatJourney.start()
    }

    @JourneyBuilder
    static func claimsChat(style: PresentationStyle = .default) -> some JourneyPresentation {
        if hAnalyticsExperiment.disableChat {
            AppJourney.disableChatScreen(style: style)
        } else {
            let chat = Chat()

            Journey(chat, style: style, options: [.embedInNavigationController, .preffersLargerNavigationBar]) {
                item in
                if case .notifications = item {
                    item.journey
                }
            }
            .onPresent {
                chat.chatState.initFetch()
            }
            .onDismiss {
                chat.chatState.reset()
            }
            .configureTitle(L10n.chatTitle)
            .setScrollEdgeNavigationBarAppearanceToStandardd
        }
    }

    static func disableChatScreen(style: PresentationStyle = .default) -> some JourneyPresentation {
        return HostingJourney(
            rootView: GenericErrorView(
                title: nil,
                description: L10n.chatDisabledMessage,
                icon: .triangle,
                buttons: .init(
                    actionButton:
                        .init(
                            buttonTitle: L10n.generalCloseButton,
                            buttonAction: {
                                let store: UgglanStore = globalPresentableStoreContainer.get()
                                store.send(.closeChat)
                            }
                        ),
                    dismissButton: nil
                )
            )
            .hWithoutTitle,
            style: style,
            options: [.embedInNavigationController, .preffersLargerNavigationBar]
        )
        .onAction(UgglanStore.self) { action in
            if case .closeChat = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.chatTitle)
    }
}
