import Flow
import Form
import Foundation
import Hero
import Presentation
import UIKit
import hCore
import hCoreUI

struct ContractDetail {
	var contractRow: ContractRow

	init(contractRow: ContractRow) {
		self.contractRow = contractRow
		self.contractRow.allowDetailNavigation = false
	}
}

extension ContractDetail: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let scrollView = FormScrollView()
		let form = FormView()

		form.appendSpacing(.inbetween)

		let (contractRowView, configureContractRow) = ContractRow.makeAndConfigure()
		bag += configureContractRow(contractRow)

		form.append(contractRowView)

		let contractInformation = ContractInformation(contract: contractRow.contract)

		let contractCoverage = ContractCoverage(
			perilFragments: contractRow.contract.perils.compactMap { $0.fragments.perilFragment },
			insurableLimitFragments: contractRow.contract.insurableLimits.compactMap {
				$0.fragments.insurableLimitFragment
			}
		)

		let contractDocuments = ContractDocuments(contract: contractRow.contract)

		var contractDetailCollection = ContractDetailCollection(
			rows: [
				ContractDetailPresentableRow(presentable: AnyPresentable(contractInformation)),
				ContractDetailPresentableRow(presentable: AnyPresentable(contractCoverage)),
				ContractDetailPresentableRow(presentable: AnyPresentable(contractDocuments)),
			],
			currentIndex: IndexPath(row: 0, section: 0)
		)

		bag += form.append(ContractDetailSegmentedControl(form: form, scrollView: scrollView)).onValue {
			index in contractDetailCollection.currentIndex = index
		}

		bag += form.append(contractDetailCollection) { contractDetailCollectionView in
			contractDetailCollectionView.hero.modifiers = [
				.translate(x: 0, y: 40, z: 0), .opacity(0), .spring(stiffness: 250, damping: 30),
			]
		}

		bag += viewController.install(form, options: [], scrollView: scrollView)

		return (viewController, bag)
	}
}
