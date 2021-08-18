import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractCoverage {
  let perilFragments: [GraphQL.PerilFragment]
  let insurableLimitFragments: [GraphQL.InsurableLimitFragment]
}

extension ContractCoverage: Presentable {
  func materialize() -> (UIViewController, Disposable) {
    let bag = DisposeBag()
    let viewController = UIViewController()
    viewController.title = L10n.contractCoverageMainTitle

    let form = FormView()

    let insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    let perilCollection = PerilCollection(
      perilFragmentsSignal: ReadWriteSignal(perilFragments).readOnly()
    )

    bag += form.append(perilCollection.insetted(insets))

    bag += form.append(Spacing(height: 20))

    bag += form.append(Divider(backgroundColor: .brand(.primaryBorderColor)))

    bag += form.append(Spacing(height: 20))

    let insurableLimits = InsurableLimits(
      insurableLimitFragmentsSignal: ReadWriteSignal(insurableLimitFragments).readOnly()
    )

    bag += form.append(insurableLimits)

    bag += viewController.install(form, options: [])

    return (viewController, bag)
  }
}
