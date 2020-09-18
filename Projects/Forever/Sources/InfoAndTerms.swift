import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import SafariServices
import UIKit

public struct InfoAndTerms {
    let potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>

    public init(
        potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>
    ) {
        self.potentialDiscountAmountSignal = potentialDiscountAmountSignal
    }
}

extension InfoAndTerms: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let closeBarButton = UIBarButtonItem(title: L10n.NavBar.close)
        viewController.navigationItem.rightBarButtonItem = closeBarButton

        var imageTextAction = ImageTextAction<Void>(
            image: .init(image: Asset.infoAndTermsIllustration.image),
            title: L10n.ReferralsInfoSheet.headline,
            body: "",
            actions: [
                (
                    (),
                    Button(
                        title: L10n.ReferralsInfoSheet.fullTermsAndConditions,
                        type: .standard(
                            backgroundColor: .brand(.primaryButtonBackgroundColor),
                            textColor: .brand(.primaryButtonTextColor)
                        )
                    )
                ),
            ],
            showLogo: false
        )

        bag += potentialDiscountAmountSignal.atOnce().compactMap { $0 }.map { L10n.ReferralsInfoSheet.body($0.formattedAmount) }.onValue { body in
            imageTextAction.body = body
        }

        return (viewController, Future { completion in
            bag += viewController.install(imageTextAction).onValue {
                viewController.present(SFSafariViewController(url: URL(string: L10n.referralsTermsWebsiteUrl)!), animated: true, completion: nil)
            }

            bag += closeBarButton.onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
