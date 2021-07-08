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
		let bag = DisposeBag()

		let footerStack = UIStackView()

		let footerDescription = UILabel(
			value: L10n.offerFooterSubtitle,
			style: .brand(.subHeadline(color: .primary))
		)
		footerDescription.textAlignment = .center

		let button = Button(
			title: L10n.offerFooterButtonText,
			type: .standardOutlineIcon(
				borderColor: .brand(.primaryText()),
				textColor: .brand(.primaryText()),
				icon: .left(image: hCoreUIAssets.chat.image, width: 24)
			)
		)

		footerStack.addArrangedSubview(footerDescription)

		let section = SectionView(
			headerView: UILabel(value: L10n.Offer.faqTitle, style: .default),
			footerView: {
				let footerStackView = UIStackView()
				footerStackView.axis = .vertical
				footerStackView.spacing = 16
				footerStackView.addArrangedSubview(footerDescription)

				bag += footerStackView.addArranged(button) { button in

				}

				return footerStackView
			}()
		)

		let rowContentContainer = UIStackView()
		rowContentContainer.isUserInteractionEnabled = true
		rowContentContainer.spacing = 8
		rowContentContainer.edgeInsets = UIEdgeInsets(inset: 16)

		let rowContentBackground = UIView()
		rowContentBackground.layer.cornerRadius = .defaultCornerRadius
		rowContentBackground.backgroundColor = .brand(.secondaryBackground())

		rowContentContainer.addArrangedSubview(rowContentBackground)

		let innerContentContainer = UIStackView()
		innerContentContainer.isUserInteractionEnabled = true
		innerContentContainer.clipsToBounds = true
		innerContentContainer.layer.cornerRadius = 8

		rowContentBackground.addSubview(innerContentContainer)
		innerContentContainer.snp.makeConstraints { make in make.edges.equalToSuperview() }

		let innerSection = SectionView()
        innerSection.dynamicStyle = .brandGrouped(separatorType: .standard, backgroundColor: .brand(.secondaryBackground()))

		bag += rowContentBackground.applyShadow { _ in
			UIView.ShadowProperties(
				opacity: 1,
				offset: CGSize(width: 0, height: 1),
				blurRadius: nil,
				color: UIColor.black.withAlphaComponent(0.1),
				path: nil,
				radius: 2
			)
		}

		innerContentContainer.append(innerSection)

		section.append(rowContentContainer)
		section.dynamicStyle = .brandGrouped(separatorType: .none)

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

					innerBag += innerSection.append(row).compactMap { _ in row.viewController }
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
						innerSection.remove(row)
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
