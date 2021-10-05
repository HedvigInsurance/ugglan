import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

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

        let insets = EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

        let perilCollection = PerilCollection(
            perils: perils,
            didTapPeril: { peril in
                form.viewController?.present(
                    PerilDetail(peril: peril).withCloseButton,
                    style: .detented(.preferredContentSize, .large)
                )
            }
        ).padding(insets)

        form.append(HostingView(rootView: perilCollection))

        bag += form.append(Spacing(height: 20))

        bag += form.append(Divider(backgroundColor: .brand(.primaryBorderColor)))

        bag += form.append(Spacing(height: 20))

        bag += form.append(InsurableLimitsSection(insurableLimits: insurableLimits))

        form.appendSpacing(.custom(20))

        bag += viewController.install(form, options: [])

        return (viewController, bag)
    }
}
