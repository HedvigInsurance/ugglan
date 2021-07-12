import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct DocumentsSection {
	let quote: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote
}

extension DocumentsSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView(
            headerView: UILabel(value: L10n.offerDocumentsSectionTitle, style: .default),
			footerView: nil
		)
        section.dynamicStyle = .brandGroupedInset(separatorType: .standard)

		let bag = DisposeBag()

		bag += quote.insuranceTerms.map { term in
			let innerBag = DisposeBag()
            
            let row = RowView(title: term.displayName, style: .brand(.body(color: .primary)))

            row.prepend(hCoreUIAssets.document.image.imageView(height: 34, width: 34))
            row.append(hCoreUIAssets.external.image.imageView(width: 20))

            innerBag += section.append(row)
				.onValue { _ in
					guard let url = URL(string: term.url) else {
						return
					}
					let viewController = SFSafariViewController(url: url)
					viewController.modalPresentationStyle = .formSheet
					section.viewController?.present(viewController, animated: true)
				}
            
            innerBag += {
                section.remove(row)
            }

			return innerBag
		}

		return (section, bag)
	}
}
