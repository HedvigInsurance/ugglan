import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hGraphQL

public struct InsurableLimitsSectionView<Header: View>: View {
    var header: Header?
    var limits: [InsurableLimits]
    var didTap: (_ limit: InsurableLimits) -> Void

    public init(
        header: Header? = nil,
        limits: [InsurableLimits],
        didTap: @escaping (InsurableLimits) -> Void
    ) {
        self.header = header
        self.limits = limits
        self.didTap = didTap
    }

    public var body: some View {
        hSection(limits, id: \.label) { limit in
            hRow {
                VStack(alignment: .leading, spacing: 4) {
                    hText(limit.label)
                    hText(limit.limit)
                        .foregroundColor(hLabelColor.secondary)
                }
            }
            .withCustomAccessory {
                Spacer()
                Image(uiImage: hCoreUIAssets.infoLarge.image)
            }
            .onTap {
                didTap(limit)
            }
        }
        .withHeader {
            header
        }
    }
}

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
