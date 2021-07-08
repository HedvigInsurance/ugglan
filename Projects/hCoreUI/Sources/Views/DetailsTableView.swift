import Flow
import Form
import Presentation
import UIKit
import hCore
import hGraphQL

extension hGraphQL.GraphQL.DetailsTableFragment: Viewable {
	public func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
		let bag = DisposeBag()

		let headerContainer = UIStackView()
		headerContainer.addArrangedSubview(
			UILabel(
				value: title,
				style: .brand(.title2(color: .primary))
			)
		)

		let sectionView = SectionView(headerView: headerContainer, footerView: nil)
		bag += {
			sectionView.removeFromSuperview()
		}

		sections.enumerated()
			.forEach { (offset, section) in
				let headerContainer = UIStackView()
				headerContainer.edgeInsets = UIEdgeInsets(
					top: offset == 0 ? 0 : 15,
					left: 0,
					bottom: 0,
					right: 0
				)
				headerContainer.addArrangedSubview(
					UILabel(
						value: section.title,
						style: .brand(.callout(color: .tertiary))
					)
				)

				let detailsSection = SectionView(
					headerView: headerContainer,
					footerView: nil
				)
				sectionView.append(detailsSection)

				section.rows.forEach { tableRow in
					let row = RowView(
						title: tableRow.title,
						subtitle: tableRow.subtitle ?? ""
					)
					detailsSection.append(row)

					let valueLabel = UILabel(
						value: tableRow.value,
						style: .brand(.body(color: .secondary))
					)
					row.append(valueLabel)
				}
			}

		return (sectionView, bag)
	}
}
