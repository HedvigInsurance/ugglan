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
        
        let footerDescription = UILabel(value: L10n.offerFooterSubtitle, style: .brand(.subHeadline(color: .primary)))
        let button = ButtonRowViewWrapper(title: L10n.offerFooterButtonText, type: .outlineIcon(borderColor: .brand(.primaryText()), textColor: .brand(.primaryText()), icon: .left(image: hCoreUIAssets.chat.image, width: 28.5)))
        
        footerStack.addArrangedSubview(footerDescription)
        
        let section = SectionView(
            headerView: UILabel(value: L10n.Offer.faqTitle, style: .default),
            footerView: nil
        )
        
        let innerSection = SectionView()
        innerSection.dynamicStyle = .brandGrouped(separatorType: .standard)
        
        let footerSection = SectionView()
        footerSection.append(RowView().append(footerDescription))
        bag += footerSection.append(button)
        footerSection.dynamicStyle = .brandGrouped(separatorType: .none)
        
        section.append(innerSection)
        section.append(footerSection)
        
        section.dynamicStyle = .brandGrouped(separatorType: .none)

		bag += state.dataSignal.compactMap { $0.quoteBundle.frequentlyAskedQuestions }
			.onValueDisposePrevious { frequentlyAskedQuestions in
				let innerBag = DisposeBag()

				innerBag += frequentlyAskedQuestions.map { frequentlyAskedQuestion in
					let innerBag = DisposeBag()
                    
					let row = RowView(title: frequentlyAskedQuestion.headline ?? "")
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

					row.append(hCoreUIAssets.chevronRight.image)

					return innerBag
				}

				return innerBag
			}

		return (section, bag)
	}
}
