import Apollo
import Contracts
import Embark
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Home
import Presentation
import UIKit

struct MovingFlow {
    @Inject var client: ApolloClient
}

extension MovingFlow: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        return (viewController, DisposeBag())
    }
}
