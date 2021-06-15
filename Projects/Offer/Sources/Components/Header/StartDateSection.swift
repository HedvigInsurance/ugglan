import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct StartDateSection { @Inject var state: OfferState }

extension GraphQL.QuoteBundleQuery.Data.QuoteBundle {
	var canHaveIndependentStartDates: Bool {
		self.quotes.count > 1 && self.inception.asIndependentInceptions != nil
	}
    
    var switcher: Bool {
        self.inception.asConcurrentInception?.currentInsurer != nil ||
        self.inception.asIndependentInceptions?.inceptions.contains(where: { inception in
            inception.currentInsurer != nil
        }) == true
    }
    
	var displayableStartDate: String {
		if let concurrentInception = self.inception.asConcurrentInception {
			return concurrentInception.startDate?.localDateToDate?.localDateStringWithToday ?? ""
		}
        
		guard let independentInceptions = self.inception.asIndependentInceptions?.inceptions else { return "" }
        
		let startDates = independentInceptions.compactMap { $0.startDate }
		let allStartDatesEqual = startDates.dropFirst().allSatisfy({ $0 == startDates.first })
		let dateDisplayValue = startDates.first?.localDateToDate?.localDateStringWithToday ?? ""
        
		return allStartDatesEqual ? dateDisplayValue : "Multiple"
	}
}

extension StartDateSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView()
		section.dynamicStyle = .brandGrouped(separatorType: .custom(55), shouldRoundCorners: { _ in false })
        
		let bag = DisposeBag()
        
		bag += state.dataSignal.map { $0.quoteBundle }
			.onValueDisposePrevious { quoteBundle in
				let row = RowView(
					title: quoteBundle.canHaveIndependentStartDates ? "Start dates" : "Start date"
				)
				let iconImageView = UIImageView()
				iconImageView.image = hCoreUIAssets.calendar.image
				row.prepend(iconImageView)
				row.setCustomSpacing(17, after: iconImageView)
				let dateLabel = UILabel(
					value: quoteBundle.displayableStartDate,
					style: .brand(.body(color: .secondary))
				)
				row.append(dateLabel)
				row.append(hCoreUIAssets.chevronRight.image)
				let innerBag = DisposeBag()
                
				innerBag += section.append(row).compactMap { _ in row.viewController }
					.onValue { viewController in
						viewController.present(
							StartDate().wrappedInCloseButton(),
							style: .detented(.large)
						)
					}
				innerBag += { section.remove(row) }
                
				return innerBag
			}
        
		return (section, bag)
	}
}
