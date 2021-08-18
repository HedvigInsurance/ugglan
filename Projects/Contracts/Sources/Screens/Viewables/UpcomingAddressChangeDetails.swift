import Flow
import Form
import Presentation
import UIKit
import hCore
import hGraphQL

public struct UpcomingAddressChangeDetails {
  let details: hGraphQL.GraphQL.DetailsTableFragment
}

extension UpcomingAddressChangeDetails: Presentable {
  public func materialize() -> (UIViewController, Disposable) {
    let viewController = UIViewController()
    let bag = DisposeBag()

    let form = FormView()

    viewController.title = L10n.InsuranceDetails.updateDetailsSheetTitle

    bag += viewController.install(form)

    bag += form.append(details)

    return (viewController, bag)
  }
}
