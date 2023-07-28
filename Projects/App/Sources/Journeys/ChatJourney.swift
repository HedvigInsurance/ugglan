import Apollo
import Foundation
import Presentation
import hCore
import hGraphQL

extension AppJourney {
    static func freeTextChat(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        let chat = Chat()

        return Journey(chat, style: style, options: [.embedInNavigationController, .preffersLargerNavigationBar]) {
            item in
            item.journey
        }
        .onPresent {
            let giraffe: hGiraffe = Dependencies.shared.resolve()

            giraffe.client.perform(mutation: GiraffeGraphQL.TriggerFreeTextChatMutation())
                .onValue { _ in
                    chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
                        chat.chatState.subscribe()
                    }
                }
                .onError { error in
                    log.error("Chat Error: TriggerFreeTextChatMutation", error: error, attributes: nil)
                    chat.chatState.errorSignal.value = (ChatError.mutationFailed, nil)
                }
        }
        .configureTitle(L10n.chatTitle)
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func claimsChat(style: PresentationStyle = .default) -> some JourneyPresentation {
        let chat = Chat()

        return Journey(chat, style: style, options: [.embedInNavigationController, .preffersLargerNavigationBar]) {
            item in
            if case .notifications = item {
                item.journey
            }
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
        .configureTitle(L10n.chatTitle)
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
}
