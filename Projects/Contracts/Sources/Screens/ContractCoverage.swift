import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractCoverage {
    let perils: [Perils]
    let insurableLimits: [InsurableLimits]
}

extension ContractCoverage: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = L10n.contractCoverageMainTitle

        let form = FormView()

        let insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        let perilCollection = PerilCollection(
            perilSignal: ReadWriteSignal(perils).readOnly()
        )

        bag += form.append(perilCollection.insetted(insets))

        bag += form.append(Spacing(height: 20))

        bag += form.append(Divider(backgroundColor: .brand(.primaryBorderColor)))

        bag += form.append(Spacing(height: 20))

        bag += form.append(InsurableLimitsSection(insurableLimits: insurableLimits))

        form.appendSpacing(.custom(20))

        bag += viewController.install(form, options: [])

        return (viewController, bag)
    }
}
