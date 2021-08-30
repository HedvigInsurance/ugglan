import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct InsurableLimits {
    let insurableLimitsSignal: ReadSignal<[ActiveContractBundle.InsurableLimits]>

    public init(
        insurableLimitsSignal: ReadSignal<[ActiveContractBundle.InsurableLimits]>
    ) {
        self.insurableLimitsSignal = insurableLimitsSignal
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

        bag += insurableLimitsSignal.atOnce()
            .onValueDisposePrevious { insurableLimitFragments in
                let innerBag = DisposeBag()

                innerBag += insurableLimitFragments.map { insurableLimitFragment in
                    let row = RowView(title: insurableLimitFragment.label)
                    row.axis = .vertical
                    row.alignment = .leading
                    row.spacing = 5
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
