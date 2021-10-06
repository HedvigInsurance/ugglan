import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct CurrentInsurerSection {
    let quoteBundle: QuoteBundle
    
    func makeSwitcherCard() -> Card {
        Card(
            titleIcon: hCoreUIAssets.restart.image,
            title: L10n.switcherAutoCardTitle,
            body: L10n.switcherAutoCardDescription,
            backgroundColor: .tint(.lavenderTwo)
        )
    }
    
    func makeManualCard() -> Card {
        Card(
            titleIcon: hCoreUIAssets.warningTriangle.image,
            title: L10n.switcherManualCardTitle,
            body: L10n.switcherManualCardDescription,
            backgroundColor: .tint(.yellowTwo)
        )
    }
}

extension CurrentInsurerSection: Presentable {
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let sectionContainer = UIStackView()
        sectionContainer.axis = .vertical
        
        sectionContainer.appendSpacing(.inbetween)
        
        let cardContainer = UIStackView()
        cardContainer.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        sectionContainer.addArrangedSubview(cardContainer)
        
        switch quoteBundle.inception {
        case .concurrent(let concurrentInception):
            let section = SectionView(
                headerView: UILabel(
                    value: L10n.Offer.switcherTitle(quoteBundle.quotes.count),
                    style: .default
                ),
                footerView: nil
            )
            section.dynamicStyle = .brandGroupedInset(separatorType: .standard)
            sectionContainer.addArrangedSubview(section)
            
            let row = RowView(title: L10n.InsuranceProvider.currentInsurer)
            section.append(row)
            
            let currentInsurerName = concurrentInception.currentInsurer?.displayName ?? ""
            let switchable = concurrentInception.currentInsurer?.switchable ?? false
            
            row.append(
                UILabel(
                    value: currentInsurerName,
                    style: .brand(.body(color: .secondary))
                )
            )
            
            if switchable {
                bag += cardContainer.addArranged(
                    makeSwitcherCard()
                )
            } else {
                bag += cardContainer.addArranged(
                    makeManualCard()
                )
            }
        case .independent(let inceptions):
            let headerText = L10n.Offer.switcherTitle(quoteBundle.quotes.count)
            
            let section = SectionView(
                headerView: UILabel(value: headerText, style: .default),
                footerView: nil
            )
            section.dynamicStyle = .brandGrouped(separatorType: .none)
            sectionContainer.addArrangedSubview(section)
            
            inceptions.enumerated()
                .forEach { offset, inception in
                    let currentInsurer = inception.currentInsurer
                    let correspondingQuoteID = inception.correspondingQuote.id
                    let switchable = inception.currentInsurer?.switchable ?? false
                    
                    let insuranceType = quoteBundle.quoteFor(id: correspondingQuoteID)?.displayName
                    
                    let inceptionSection = SectionView(
                        headerView: UILabel(
                            value: insuranceType ?? "",
                            style: .default
                        ),
                        footerView: {
                            let stackView = UIStackView()
                            
                            if switchable {
                                bag += stackView.addArranged(
                                    makeSwitcherCard()
                                )
                            } else {
                                bag += stackView.addArranged(
                                    makeManualCard()
                                )
                            }
                            
                            return stackView
                        }()
                    )
                    inceptionSection.dynamicStyle = .brandGroupedInset(separatorType: .standard)
                    section.append(inceptionSection)
                    
                    let row = RowView(title: currentInsurer?.displayName ?? "")
                    inceptionSection.append(row)
                }
        case .unknown:
            break
        }
        
        
        return (sectionContainer, bag)
    }
}
