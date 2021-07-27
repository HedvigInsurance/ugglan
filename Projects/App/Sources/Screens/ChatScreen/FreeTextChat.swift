import Apollo
import Flow
import Form
import Presentation
import UIKit
import hCore
import hGraphQL

struct FreeTextChat { @Inject var client: ApolloClient }

extension FreeTextChat: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let bag = DisposeBag()
		let chat = Chat()
		let (viewController, signal) = chat.materialize()

		viewController.navigationItem.titleView = .titleWordmarkView

		bag += client.perform(mutation: GraphQL.TriggerFreeTextChatMutation())
			.onValue { _ in
				chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
					chat.chatState.subscribe()
				}
			}
        
        bag += signal.nil()

		return (
			viewController,
			bag
		)
	}
}
