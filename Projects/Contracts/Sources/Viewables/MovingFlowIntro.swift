import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct MovingFlowIntro {
    @Inject var client: ApolloClient
}

enum MovingFlowIntroState {
    case manual
    case existing
    case normal
}

extension MovingFlowIntro: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let form = FormView()

        bag += viewController.install(form)

        client.fetch(query: GraphQL.SelfChangeElibilityQuery()).onValue { data in
            if let storyId = data.selfChangeEligibility.embarkStoryId {
            } else {}
        }

        return (viewController, bag)
    }
}
