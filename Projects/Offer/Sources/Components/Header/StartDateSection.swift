import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct StartDateSection {}

extension QuoteBundle {
    var canHaveIndependentStartDates: Bool {
        switch inception {
        case .independent:
            return quotes.count > 1
        default:
            return false
        }
    }

    var switcher: Bool {
        switch inception {
        case let .concurrent(inception):
            return inception.currentInsurer != nil
        case let .independent(independentInceptions):
            return independentInceptions.contains { inception in
                inception.currentInsurer != nil
            } == true
        case .unknown:
            return false
        }
    }

    var fallbackDisplayValue: String {
        if switcher {
            return L10n.startDateExpires
        }

        return Date().localDateStringWithToday ?? ""
    }

    var displayableStartDate: String {
        switch inception {
        case .concurrent(let concurrentInception):
            return concurrentInception.startDate?.localDateToDate?.localDateStringWithToday ?? ""
        case .independent(let independentInceptions):
            let startDates = independentInceptions.map { $0.startDate }
            let allStartDatesEqual = startDates.dropFirst().allSatisfy({ $0 == startDates.first })
            let dateDisplayValue =
                startDates.first??.localDateToDate?.localDateStringWithToday ?? fallbackDisplayValue
            
            return allStartDatesEqual ? dateDisplayValue : L10n.offerStartDateMultiple
        case .unknown:
            return ""
        }
    }
}

extension QuoteBundle {
    var startDateTerminology: String {
        switch appConfiguration.startDateTerminology {
        case .startDate:
            return self.canHaveIndependentStartDates
                ? L10n.offerStartDatePlural : L10n.offerStartDate
        case .accessDate:
            return L10n.offerAccessDate
        case .unknown:
            return ""
        }
    }
}

extension StartDateSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView()
        
        let store: OfferStore = self.get()
        
        section.dynamicStyle = .brandGroupedInset(
            separatorType: .none,
            border: .init(
                width: 1,
                color: .brand(.primaryBorderColor),
                cornerRadius: .defaultCornerRadius,
                borderEdges: .all
            ),
            appliesShadow: false
        )

        let bag = DisposeBag()

        bag += store.stateSignal.compactMap { $0.offerData?.quoteBundle }
            .onValueDisposePrevious { quoteBundle in
                let innerBag = DisposeBag()

                let quoteBundle = quoteBundle

                let displayableStartDate = quoteBundle.displayableStartDate

                let row = RowView(
                    title: quoteBundle.startDateTerminology
                )
                row.titleLabel?.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                let iconImageView = UIImageView()
                iconImageView.image = hCoreUIAssets.calendar.image
                row.prepend(iconImageView)
                row.setCustomSpacing(17, after: iconImageView)

                let dateStyledText = StyledText(
                    text: displayableStartDate,
                    style: .brand(.body(color: .secondary))
                )

                let dateLabel = UILabel(
                    styledText: dateStyledText
                )
                dateLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                row.append(dateLabel)

                innerBag += dateLabel.didLayoutSignal.onValue {
                    let rect = NSAttributedString(styledText: dateStyledText)
                        .boundingRect(
                            with: CGSize(width: CGFloat(Int.max), height: CGFloat(Int.max)),
                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                            context: nil
                        )

                    if rect.width > dateLabel.frame.width {
                        row.subtitle = displayableStartDate
                        dateLabel.isHidden = true
                    } else {
                        dateLabel.isHidden = false
                        row.subtitle = nil
                    }
                }

                row.append(hCoreUIAssets.chevronRight.image)

                innerBag += section.append(row).compactMap { _ in row.viewController }
                    .onValue { viewController in
                        viewController.present(
                            StartDate(quoteBundle: quoteBundle).wrappedInCloseButton(),
                            style: .detented(.large)
                        )
                    }
                innerBag += { section.remove(row) }

                return innerBag
            }

        return (section, bag)
    }
}
