import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct CurrentInsurerSection {
    @Inject var state: OfferState
}

extension CurrentInsurerSection: Presentable {
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let sectionContainer = UIStackView()
        sectionContainer.axis = .vertical

        let section = SectionView(
            headerView: UILabel(value: "Your current insurance", style: .default),
            footerView: nil
        )
        sectionContainer.addArrangedSubview(section)

        bag += state.dataSignal.compactMap{ $0.quoteBundle.inception }.onValueDisposePrevious { inception in
            let innerBag = DisposeBag()

            innerBag += inception.asIndependentInceptions?.inceptions.map { inception in
                let row = RowView(title: "Current insurer")
                section.append(row)

                row.append(
                    UILabel(
                        value:  inception.currentInsurer?.displayName ?? "",
                        style: .brand(.body(color: .secondary))
                    )
                )

                return Disposer {
                    section.remove(row)
                }
            }
            let cardContainer = UIStackView()
            cardContainer.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 5)
            sectionContainer.addArrangedSubview(cardContainer)
            
            let switchingCard = Card(
                titleIcon: hCoreUIAssets.apartment.image,
                title: "Switching from Folksam",
                body: "It only takes a minute with BankID and your new insurance with Hedvig is activated the same day as your old one from Folksam expires.",
                backgroundColor: .tint(.lavenderTwo)
            )
            
            innerBag += cardContainer.addArranged(switchingCard)
            
            return innerBag
        }

        return (sectionContainer, bag)
    }
}

