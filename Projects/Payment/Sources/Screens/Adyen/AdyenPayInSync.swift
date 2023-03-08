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

        activityIndicator.style = .large

        form.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(scrollView.frameLayoutGuide.snp.center)
        }

        activityIndicator.startAnimating()

        return (
            viewController,
            FiniteSignal { callback in
                client.fetch(query: GiraffeGraphQL.ActivePaymentMethodsQuery())
                    .onError({ error in
                        print(error)
                    })
                    .join(with: AdyenMethodsList.payInOptions)
                    .onValue { paymentMethods, options in
                        if paymentMethods.activePaymentMethodsV2 == nil {
                            callback(.value(.left(options)))
                        } else if case .replacement = setupType {
                            callback(.value(.left(options)))
                        } else if case .preOnboarding = setupType {
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
