import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct BulletPointTable {
	let bulletPoints: [GraphQL.CommonClaimsQuery.Data.CommonClaim.Layout.AsTitleAndBulletPoints.BulletPoint]
}

extension BulletPointTable: Viewable {
	func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
		let bag = DisposeBag()

		let sectionStyle = SectionStyle(
			insets: .zero,
			rowInsets: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15),
			itemSpacing: 0,
			minRowHeight: 10,
			background: .none,
			selectedBackground: .none,
			shadow: .none,
			header: .none,
			footer: .none
		)

		let dynamicSectionStyle = DynamicSectionStyle { _ in sectionStyle }

		let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

		let tableKit = TableKit<EmptySection, BulletPointCard>(style: style, holdIn: bag)
		tableKit.view.isScrollEnabled = false

		let rows = bulletPoints.map {
			BulletPointCard(
				title: $0.title,
				icon: RemoteVectorIcon($0.icon.fragments.iconFragment),
				description: $0.description
			)
		}

		bag += tableKit.delegate.willDisplayCell.onValue { cell, indexPath in
			cell.layer.zPosition = CGFloat(indexPath.row)
		}

		tableKit.set(Table(rows: rows), rowIdentifier: { $0.title })

		bag += tableKit.view.signal(for: \.contentSize)
			.onValue { contentSize in
				tableKit.view.snp.updateConstraints { make in make.height.equalTo(contentSize.height) }
			}

		return (tableKit.view, bag)
	}
}
