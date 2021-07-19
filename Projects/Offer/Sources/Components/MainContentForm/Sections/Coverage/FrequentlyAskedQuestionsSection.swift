import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct FrequentlyAskedQuestionsSection {
	@Inject var state: OldOfferState
}

extension FrequentlyAskedQuestionsSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let bag = DisposeBag()

		let section = SectionView(
			headerView: UILabel(value: L10n.Offer.faqTitle, style: .default),
			footerView: {
				let footerStackView = UIStackView()
				footerStackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 15)
				footerStackView.axis = .vertical
				footerStackView.spacing = 16

				let footerDescription = UILabel(
					value: L10n.offerFooterSubtitle,
					style: .brand(.subHeadline(color: .primary)).aligned(to: .center)
				)

				footerStackView.addArrangedSubview(footerDescription)

				let button = Button(
					title: L10n.offerFooterButtonText,
					type: .standardOutlineIcon(
						borderColor: .brand(.primaryText()),
						textColor: .brand(.primaryText()),
						icon: .left(image: hCoreUIAssets.chat.image, width: 24)
					)
				)
                
                bag += button.onTapSignal.onValue { _ in
                    let store: OfferStore = self.get()
                    store.send(.openChat)
                }

				bag += footerStackView.addArranged(button)

				return footerStackView
			}()
		)
		section.dynamicStyle = .brandGroupedInset(separatorType: .standard)

		bag += state.dataSignal.compactMap { $0.quoteBundle.frequentlyAskedQuestions }
			.onValueDisposePrevious { frequentlyAskedQuestions in
				let innerBag = DisposeBag()

				innerBag += frequentlyAskedQuestions.map { frequentlyAskedQuestion in
					let innerBag = DisposeBag()

					let titleLabel = MultilineLabel(
						value: frequentlyAskedQuestion.headline ?? "",
						style: .brand(.body(color: .primary))
					)

					let row = RowView()
					innerBag += row.append(titleLabel)

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

					let imageView = UIImageView()
					imageView.image = hCoreUIAssets.chevronRight.image
					imageView.setContentHuggingPriority(.required, for: .horizontal)

					row.append(imageView)

					return innerBag
				}

				return innerBag
			}

		return (section, bag)
	}
}
