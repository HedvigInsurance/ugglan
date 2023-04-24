import Apollo
import Foundation
import Presentation
import hCore
import hGraphQL

extension AppJourney {
    static func freeTextChat(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        let chat = Chat()

        return Journey(chat, style: style) { _ in
            ContinueJourney()
        }
        .onPresent {
            let giraffe: hGiraffe = Dependencies.shared.resolve()

            giraffe.client.perform(mutation: GiraffeGraphQL.TriggerFreeTextChatMutation())
                .onValue { _ in
                    chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
                        chat.chatState.subscribe()
                    }
                }.onError { error in
                    log.error("Chat Error: TriggerFreeTextChatMutation", error: error, attributes: nil)
                    chat.chatState.errorSignal.value = (ChatError.mutationFailed, nil)
                }
        }
        .addConfiguration { presenter in
            presenter.viewController.navigationItem.titleView = .titleWordmarkView
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func claimsChat(style: PresentationStyle = .default) -> some JourneyPresentation {
        let chat = Chat()

        return Journey(chat, style: style) { _ in
            ContinueJourney()
        }
        .onPresent {
            let giraffe: hGiraffe = Dependencies.shared.resolve()

            giraffe.client.perform(mutation: GiraffeGraphQL.TriggerFreeTextChatMutation())
                .onValue { _ in
                    chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
                        chat.chatState.subscribe()
                    }
                }
        }
        .addConfiguration { presenter in
            presenter.viewController.title = L10n.claimsChatTitle
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
}
