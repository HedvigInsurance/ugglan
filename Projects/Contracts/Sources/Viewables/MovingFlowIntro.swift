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

typealias Contract = GraphQL.UpcomingAgreementQuery.Data.Contract

enum MovingFlowIntroState {
    case manual(Contract)
    case existing
    case normal
}

extension MovingFlowIntro: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let form = FormView()

        bag += viewController.install(form)

        func showSections(for state: MovingFlowIntroState) {
            switch state {
            case let .manual(contract):
                contract.status.asActiveStatus?.upcomingAgreementChange!.newAgreement.asSwedishHouseAgreement?.address
            case .existing:
                break
            case .normal:
                break
            }
        }

        client.fetch(query: GraphQL.UpcomingAgreementQuery()).onValue { data in
            if let contract = data.contracts.first {
                showSections(for: .manual(contract))
            } else {
                client.fetch(query: GraphQL.SelfChangeElibilityQuery()).onValue { data in
                    if let storyId = data.selfChangeEligibility.embarkStoryId {
                        showSections(for: .normal)
                    } else {
                        showSections(for: .existing)
                    }
                }
            }
        }

        return (viewController, bag)
    }
}
