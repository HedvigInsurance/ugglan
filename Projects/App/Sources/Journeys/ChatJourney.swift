import Apollo
import Foundation
import Presentation
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    @JourneyBuilder
    static func freeTextChat(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        if hAnalyticsExperiment.disableChat {
            AppJourney.disableChatScreen(style: style)
        } else {
            let chat = Chat()
            Journey(chat, style: style, options: [.embedInNavigationController, .preffersLargerNavigationBar]) {
                item in
                item.journey
            }
            .onPresent {
                chat.chatState.initFetch()
            }
            .onDismiss {
                chat.chatState.reset()
            }
            .configureTitle(L10n.chatTitle)
        }
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
        }
    }

    static func disableChatScreen(style: PresentationStyle = .default) -> some JourneyPresentation {
        return HostingJourney(
            rootView: RetryView(
                title: nil,
                subtitle: L10n.chatDisabledMessage,
                retryTitle: L10n.generalCloseButton,
                action: {
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.closeChat)
                }
            ),
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
