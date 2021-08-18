import Apollo
import Flow
import Form
import Presentation
import UIKit
import hCore
import hGraphQL

struct ClaimsChat { @Inject var client: ApolloClient }

extension ClaimsChat: Presentable {
  func materialize() -> (UIViewController, Disposable) {
    let bag = DisposeBag()

    let chat = Chat()
    let (viewController, future) = chat.materialize()
    viewController.navigationItem.hidesBackButton = true

    bag += client.perform(mutation: GraphQL.TriggerClaimChatMutation())
      .onValue { _ in chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) }

    viewController.title = L10n.claimsChatTitle

    bag += future.onValue { _ in }

    return (viewController, bag)
  }
}
