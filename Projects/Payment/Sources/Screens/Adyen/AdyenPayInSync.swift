import Adyen
import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct AdyenPayInSync {
    @Inject var client: ApolloClient

    let setupType: PaymentSetup.SetupType
    let urlScheme: String
}

extension AdyenPayInSync: Presentable {
    func materialize() -> (UIViewController, FiniteSignal<Either<AdyenOptions, Void>>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()
        let scrollView = FormScrollView()
        bag += viewController.install(form, scrollView: scrollView)

        let activityIndicator = UIActivityIndicatorView()

        if #available(iOS 13.0, *) { activityIndicator.style = .large }

        form.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(scrollView.frameLayoutGuide.snp.center)
        }

        activityIndicator.startAnimating()

        return (
            viewController,
            FiniteSignal { callback in
                client.fetch(query: GraphQL.ActivePaymentMethodsQuery())
                    .join(with: AdyenMethodsList.payInOptions)
                    .onValue { paymentMethods, options in
                        if paymentMethods.activePaymentMethodsV2 == nil || setupType == .replacement {
                            callback(.value(.left(options)))
                        } else {
                            callback(.value(.right(())))
                        }
                    }

                return bag
            }
        )
    }
}
