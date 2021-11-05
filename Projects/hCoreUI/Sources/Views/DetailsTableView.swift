import Flow
import Form
import Presentation
import UIKit
import hCore
import hGraphQL

extension DetailAgreementsTable: Viewable {
    public func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let sectionView: SectionView

        if !title.isEmpty {
            let headerContainer = UIStackView()

            headerContainer.addArrangedSubview(
                UILabel(
                    value: title,
                    style: .brand(.title2(color: .primary))
                )
            )

            sectionView = SectionView(headerView: headerContainer, footerView: nil)
        } else {
            sectionView = SectionView(headerView: nil, footerView: nil)
        }

        sectionView.dynamicStyle = .brandGrouped(separatorType: .none)
        bag += {
            sectionView.removeFromSuperview()
        }

        sections.enumerated()
            .forEach { (offset, section) in
                let headerContainer = UIStackView()
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
                detailsSection.dynamicStyle = .brandGroupedInset(separatorType: .standard)
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

                sectionView.appendSpacing(.inbetween)
            }

        return (sectionView, bag)
    }
}
