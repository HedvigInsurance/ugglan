import Flow
import Form
import Foundation
import hCore
import hGraphQL
import UIKit

public class ExtraBuildingRow {
	let data: ReadWriteSignal<GraphQL.ExtraBuildingFragment>

	public init(data: ReadWriteSignal<GraphQL.ExtraBuildingFragment>) { self.data = data }
}

extension ExtraBuildingRow: Viewable {
	public func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
		let bag = DisposeBag()
		let row = RowView()

		let contentView = UIStackView()
		contentView.axis = .vertical
		contentView.spacing = 5
		contentView.layoutMargins = UIEdgeInsets(inset: 15)

		let titleLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
		contentView.addArrangedSubview(titleLabel)

		bag += data.atOnce().map { $0.displayName }.onValue { displayName in titleLabel.text = displayName }

		let subtitleLabel = UILabel(value: "", style: .brand(.subHeadline(color: .secondary)))
		contentView.addArrangedSubview(subtitleLabel)

		bag += data.atOnce().map { (String($0.area), $0.hasWaterConnected) }
			.onValue { area, hasWaterConnected in let baseText = L10n.myHomeRowSizeValue(area)

				if hasWaterConnected {
					subtitleLabel.text = L10n.myHomeBuildingHasWaterSuffix(baseText)
				} else {
					subtitleLabel.text = baseText
				}
			}

		row.append(contentView)

		return (row, bag)
	}
}
