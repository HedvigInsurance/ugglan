import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct InsurableLimitsSection {
    let insurableLimits: [InsurableLimits]

    public init(
        insurableLimits: [InsurableLimits]
    ) {
        self.insurableLimits = insurableLimits
    }
}

extension InsurableLimitsSection: Viewable {
    public func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            headerView: UILabel(value: L10n.contractCoverageMoreInfo, style: .default),
            footerView: nil
        )
        section.dynamicStyle = .brandGroupedInset(separatorType: .standard)

        insurableLimits.forEach { insurableLimit in
            let row = RowView(title: insurableLimit.label)
            row.axis = .vertical
            row.alignment = .leading
            row.spacing = 5
            section.append(row)

            row.append(
                UILabel(
                    value: insurableLimit.limit,
                    style: .brand(.body(color: .secondary))
                )
            )
        }

        return (section, bag)
    }
}
