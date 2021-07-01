import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct DiscountCodeSection {
    @Inject var state: OfferState
}

extension DiscountCodeSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView()
        section.isHidden = true
		section.dynamicStyle = DynamicSectionStyle.brandGroupedNoBackground.rowInsets(
			UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
		)
		let bag = DisposeBag()
        
        bag += state.dataSignal.compactMap { $0.quoteBundle.appConfiguration.showCampaignManagement }.onValue { showCampaignManagement in
            section.isHidden = !showCampaignManagement
        }

		let row = RowView()
		section.append(row)

		let button = Button(
			title: "Add discount code",
			type: .iconTransparent(
				textColor: .brand(.primaryText()),
				icon: .left(image: hCoreUIAssets.circularPlus.image, width: 20)
			)
		)
		bag += row.append(button.alignedTo(alignment: .center))

		bag += button.onTapSignal.onValue { _ in
			let addDiscountSheet = DiscountSheet()
			section.viewController?
				.present(
					addDiscountSheet.wrappedInCloseButton(),
					style: .detented(.scrollViewContentSize(20), .large),
					options: [
						.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never),
					]
				)
		}

		return (section, bag)
	}
}
