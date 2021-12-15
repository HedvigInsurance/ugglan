import Adyen
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct AdyenPayInSync { let urlScheme: String }

extension AdyenPayInSync: Presentable {
    func materialize() -> (UIViewController, FiniteSignal<Bool>) {
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
                AdyenMethodsList.payInOptions.onValue { options in
                    bag +=
                        viewController.present(
                            AdyenPayIn(adyenOptions: options, urlScheme: urlScheme)
                        )
                        .atEnd {
                            callback(.end)
                        }
                        .onValue({ success in
                            callback(.value(success))
                        })
                }

                return bag
            }
        )
    }
}
