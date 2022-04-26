import Apollo
import Flow
import Foundation
import Presentation
import UIKit

struct ApolloClientSaveTokenLoader: Presentable {
    let accessToken: String

    func materialize() -> (UIViewController, Signal<()>) {
        let viewController = PlaceholderViewController()

        let bag = DisposeBag()

        return (
            viewController,
            Signal { callback in
                ApolloClient.saveToken(token: accessToken)

                ApolloClient.initAndRegisterClient()
                    .onValue { _ in
                        callback(())
                    }

                return bag
            }
        )
    }
}
