import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct InsurableLimits {
	let insurableLimitFragmentsSignal: ReadSignal<[GraphQL.InsurableLimitFragment]>

	public init(
		insurableLimitFragmentsSignal: ReadSignal<[GraphQL.InsurableLimitFragment]>
	) {
		self.insurableLimitFragmentsSignal = insurableLimitFragmentsSignal
	}
}

extension InsurableLimits: Viewable {
	public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()

		let section = SectionView(
			headerView: UILabel(value: L10n.contractCoverageMoreInfo, style: .default),
			footerView: nil
		)
		section.dynamicStyle = .brandGroupedInset(separatorType: .standard)

		bag += insurableLimitFragmentsSignal.atOnce()
			.onValueDisposePrevious { insurableLimitFragments in
				let innerBag = DisposeBag()

				innerBag += insurableLimitFragments.map { insurableLimitFragment in
					let row = RowView(title: insurableLimitFragment.label)
					section.append(row)

					row.append(
						UILabel(
							value: insurableLimitFragment.limit,
							style: .brand(.body(color: .secondary))
						)
					)

					return Disposer {
						section.remove(row)
					}
				}

				return innerBag
			}

		return (section, bag)
	}
}
