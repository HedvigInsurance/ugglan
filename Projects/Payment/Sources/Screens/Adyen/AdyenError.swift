import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hAnalytics

enum AdyenError: Error { case cancelled, tokenization, action, failed }

extension AdyenError: Presentable {
    func materialize() -> (UIViewController, FiniteSignal<Void>) {
        let tryAgainButton = Button(
            title: L10n.PayInError.retryButton,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        let cancelButton = Button(
            title: L10n.PayInError.postponeButton,
            type: .standardOutline(borderColor: .brand(.primaryText()), textColor: .brand(.primaryText()))
        )

        let didFailAction = ImageTextAction<Bool>(
            image: .init(
                image: hCoreUIAssets.warningTriangle.image,
                size: CGSize(width: 32, height: 32),
                contentMode: .scaleAspectFit,
                insets: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
            ),
            title: L10n.PayInError.headline,
            body: L10n.PayInError.body,
            actions: [
                (true, tryAgainButton),
                ApplicationState.currentState == .loggedIn ? (false, cancelButton) : nil,
            ]
            .compactMap { $0 },
            showLogo: false
        )

        let (viewController, signal) = PresentableViewable(viewable: didFailAction) { viewController in
            viewController.navigationItem.hidesBackButton = true
        }
        .materialize()

        return (
            viewController,
            FiniteSignal { callback in
                let bag = DisposeBag()
                
                bag += viewController.trackDidMoveToWindow(hAnalyticsEvent.screenViewConnectPaymentFailed())

                bag += signal.onValue { shouldRetry in
                    if shouldRetry {
                        callback(.value(()))
                    } else {
                        callback(.end)
                    }
                }

                return DelayedDisposer(bag, delay: 2)
            }
        )
    }
}
