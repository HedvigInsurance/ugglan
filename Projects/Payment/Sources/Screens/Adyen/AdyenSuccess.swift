import Adyen
import Flow
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI

struct AdyenSuccess { let paymentMethod: PaymentMethod }

extension AdyenSuccess: Presentable {
    func materialize() -> (UIViewController, FiniteSignal<Void>) {
        let continueButton = Button(
            title: L10n.PayInConfirmation.continueButton,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        let continueAction = ImageTextAction<Void>(
            image: .init(
                image: hCoreUIAssets.circularCheckmark.image,
                size: CGSize(width: 32, height: 32),
                contentMode: .scaleAspectFit,
                insets: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
            ),
            title: L10n.AdyenConfirmation.headline(paymentMethod.name),
            body: "",
            actions: [((), continueButton)],
            showLogo: false,
            alignment: .left
        )

        let (viewController, signal) = PresentableViewable(viewable: continueAction) { viewController in
            viewController.navigationItem.hidesBackButton = true
        }
        .materialize()

        return (
            viewController,
            FiniteSignal { callback in
                let bag = DisposeBag()

                viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .connectPaymentSuccess))
                viewController.trackOnAppear(hAnalyticsEvent.paymentConnected())

                bag += signal.onValue {
                    callback(.value(()))
                }

                return DelayedDisposer(bag, delay: 2)
            }
        )
    }
}
