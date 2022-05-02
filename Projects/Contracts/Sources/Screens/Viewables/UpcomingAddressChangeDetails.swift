import Flow
import Form
import Presentation
import UIKit
import hCore
import hGraphQL

public struct UpcomingAddressChangeDetails {
    let details: DetailAgreementsTable
}

extension UpcomingAddressChangeDetails: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()

        viewController.title = L10n.InsuranceDetails.updateDetailsSheetTitle

        bag += viewController.install(form)
        
        let hostView = makeHost {
            details.view
        }
        
        bag += {
            hostView.removeFromSuperview()
        }
        
        form.append(hostView)

        return (viewController, bag)
    }
}
