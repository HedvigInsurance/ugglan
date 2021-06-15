import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct FrequentlyAskedQuestionsSection {
	@Inject var state: OfferState
}

extension FrequentlyAskedQuestionsSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView(
			headerView: UILabel(value: "Common questions", style: .default),
			footerView: nil
		)
		section.dynamicStyle = .brandGrouped(separatorType: .none)

		let bag = DisposeBag()

		bag += state.dataSignal.compactMap { $0.quoteBundle.frequentlyAskedQuestions }
			.onValueDisposePrevious { frequentlyAskedQuestions in
				let innerBag = DisposeBag()

				innerBag += frequentlyAskedQuestions.map { frequentlyAskedQuestion in
					let innerBag = DisposeBag()

					let row = RowView(title: frequentlyAskedQuestion.headline ?? "")
					innerBag += section.append(row).compactMap { _ in row.viewController }
						.onValue { viewController in
							viewController.present(
								FrequentlyAskedQuestionDetail(
									frequentlyAskedQuestion: frequentlyAskedQuestion
								)
								.withCloseButton,
								style: .detented(.preferredContentSize)
							)
						}

					innerBag += Disposer {
						section.remove(row)
					}

					row.append(hCoreUIAssets.chevronRight.image)

					return innerBag
				}

				return innerBag
			}

		return (section, bag)
	}
}
