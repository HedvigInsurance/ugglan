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
    @Cached var moveData: Data?
}

extension MovingFlow: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        if let moveData = moveData {}

        return (viewController, DisposeBag())
    }
}
