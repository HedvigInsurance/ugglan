import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct FrequentlyAskedQuestionDetail {
	let frequentlyAskedQuestion: GraphQL.QuoteBundleQuery.Data.QuoteBundle.FrequentlyAskedQuestion
}

extension FrequentlyAskedQuestionDetail: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let stackView = UIStackView()
		stackView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 20)
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.axis = .vertical
		stackView.spacing = 8

		bag += stackView.addArranged(
			MultilineLabel(
				value: frequentlyAskedQuestion.headline ?? "",
				style: .brand(.title3(color: .primary))
			)
		)

		bag += stackView.addArranged(
			MultilineLabel(
				value: frequentlyAskedQuestion.body ?? "",
				style: .brand(.body(color: .secondary))
			)
		)

		let view = UIView()
		view.backgroundColor = .brand(.secondaryBackground())
		view.addSubview(stackView)
		viewController.view = view

		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		bag += stackView.didLayoutSignal.onValue { _ in
			viewController.preferredContentSize = stackView.systemLayoutSizeFitting(.zero)
		}

		return (viewController, bag)
	}
}
