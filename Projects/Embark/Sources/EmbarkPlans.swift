import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SnapKit
import UIKit

public struct EmbarkPlans {
    @Inject var client: ApolloClient
    let plansSignal = ReadWriteSignal<[GraphQL.ChoosePlanQueryQuery.Data.EmbarkStory]>([])
    public init() {}
}

extension EmbarkPlans: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        
        viewController.navigationItem.title = "Choose plan"
        
        
        let tableKit = TableKit<String, PlanRow>(style: .brandInset, holdIn: bag)
        
        let containerView = UIView()
        viewController.view = containerView

        containerView.addSubview(tableKit.view)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        
        containerView.addSubview(activityIndicator)
        
        tableKit.view.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let continueButton = Button(title: "Continue", type: .standard(backgroundColor: .black, textColor: .white))
        
        bag += containerView.add(continueButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
            }
            
            bag += buttonView.didLayoutSignal.onValue {
                let bottomInset = buttonView.frame.height - buttonView.safeAreaInsets.bottom
                tableKit.view.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
                tableKit.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
            }
        }
        
        bag += client.fetch(
            query: GraphQL.ChoosePlanQueryQuery(locale: Localization.Locale.currentLocale.code)
        ).valueSignal.compactMap { $0.embarkStories }.atError({ _ in
            
        }).onValue {
            activityIndicator.removeFromSuperview()
            
            plansSignal.value = $0
        }
        
        bag += plansSignal.atOnce().compactMap { $0 }.onValue { plans in
            var table = Table(
                sections: [
                    (
                        L10n.ReferralsActive.Invited.title,
                        plans.map { PlanRow(title: $0.title, discount: $0.name, message: $0.description) }
                    ),
                ]
            )
            table.removeEmptySections()
            tableKit.set(table)
        }
        
        return (viewController, bag)
    }
}
