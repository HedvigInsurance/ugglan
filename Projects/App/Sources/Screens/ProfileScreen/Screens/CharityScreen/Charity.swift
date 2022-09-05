import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct Charity { @Inject var client: ApolloClient }

extension Charity: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = L10n.myCharityScreenTitle

        let scrollView = FormScrollView()
        let form = FormView()

        bag += client.watch(query: GraphQL.SelectedCharityQuery()).map { $0.cashback }.buffer()
            .onValueDisposePrevious { cashbacks in
                guard let cashback = cashbacks.last else { return NilDisposer() }

                let innerBag = DisposeBag()

                if cashback != nil {
                    scrollView.isScrollEnabled = true
                    let selectedCharity = SelectedCharity(
                        animateEntry: cashbacks.count > 1,
                        presentingViewController: viewController
                    )
                    innerBag += form.append(selectedCharity)
                }

                return innerBag
            }

        bag += viewController.install(form, scrollView: scrollView)

        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .charity))

        return (viewController, bag)
    }
}
