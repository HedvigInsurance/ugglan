import Foundation
import Presentation
import Apollo
import hCore
import hGraphQL

extension AppJourney {
    static func freeTextChat(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        let chat = Chat()
        
        return Journey(chat, style: style) { _ in
            ContinueJourney()
        }
            .onPresent {
            let client: ApolloClient = Dependencies.shared.resolve()
            
            client.perform(mutation: GraphQL.TriggerFreeTextChatMutation())
                .onValue { _ in
                    chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
                        chat.chatState.subscribe()
                    }
                }
            }.addConfiguration { presenter in
                presenter.viewController.navigationItem.titleView = .titleWordmarkView
            }
    }
    
    static func claimsChat(style: PresentationStyle = .default) -> some JourneyPresentation {
        let chat = Chat()
        
        return Journey(chat, style: style) { _ in
            ContinueJourney()
        }
            .onPresent {
            let client: ApolloClient = Dependencies.shared.resolve()
            
                client.perform(mutation: GraphQL.TriggerClaimChatMutation())
                .onValue { _ in
                    chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
                        chat.chatState.subscribe()
                    }
                }
            }.addConfiguration { presenter in
                presenter.viewController.title = L10n.claimsChatTitle
            }
    }
}
