import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

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

		let perilCollection = ContractPerilCollection(
			perilFragmentsSignal: ReadWriteSignal(perilFragments).readOnly()
		)

		bag += form.append(perilCollection.insetted(insets))

		bag += form.append(Spacing(height: 20))

		bag += form.append(Divider(backgroundColor: .brand(.primaryBorderColor)))

		bag += form.append(Spacing(height: 20))

		bag += form.append(
			MultilineLabel(value: L10n.contractCoverageMoreInfo, style: .brand(.headline(color: .primary)))
				.insetted(insets)
		)

		bag += form.append(Spacing(height: 10))

		let insurableLimits = ContractInsurableLimits(
			insurableLimitFragmentsSignal: ReadWriteSignal(insurableLimitFragments).readOnly()
		)

		bag += form.append(insurableLimits.insetted(insets))

		bag += viewController.install(form, options: [])

		return (viewController, bag)
	}
}
