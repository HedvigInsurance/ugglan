import Apollo
import Flow
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

struct CallMeChat {
    @Inject var client: ApolloClient
}

extension CallMeChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let chat = Chat()
        let (viewController, future) = chat.materialize()

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        bag += client.perform(mutation: GraphQL.TriggerCallMeChatMutation()).onValue { _ in
            chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData)
        }

        return (viewController, Future { completion in
            bag += future.onResult { result in
                completion(result)
            }

            return Disposer {
                future.cancel()
                bag.dispose()
            }
        })
    }
}
