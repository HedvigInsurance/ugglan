import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

struct CallMeChat { @Inject var client: ApolloClient }

extension CallMeChat: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let bag = DisposeBag()
		let chat = Chat()
		let (viewController, future) = chat.materialize()

		viewController.navigationItem.titleView = .titleWordmarkView

		bag += client.perform(mutation: GraphQL.TriggerCallMeChatMutation())
			.onValue { _ in chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) }

		return (
			viewController,
			Future { completion in bag += future.onResult { result in completion(result) }

				return Disposer {
					future.cancel()
					bag.dispose()
				}
			}
		)
	}
}
