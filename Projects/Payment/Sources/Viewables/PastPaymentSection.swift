import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PastPaymentsSection {
    @Inject var giraffe: hGiraffe
    let presentingViewController: UIViewController
}

extension PastPaymentsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(header: L10n.paymentsSubtitlePaymentHistory, footer: nil)

        let dataSignal = client.watch(
            query: GiraffeGraphQL.MyPaymentQuery(
                locale: Localization.Locale.currentLocale.asGraphQLLocale()
            )
        )
        bag += dataSignal.map { $0.chargeHistory.isEmpty }.bindTo(section, \.isHidden)

        bag += dataSignal.onValueDisposePrevious { data -> Disposable? in let innerBag = DisposeBag()

            innerBag += data.chargeHistory.prefix(2)
                .map { chargeHistory -> Disposable in let row = KeyValueRow()
                    row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

                    let dateParsingFormatter = DateFormatter()
                    dateParsingFormatter.dateFormat = "yyyy-MM-dd"

                    if let date = dateParsingFormatter.date(from: chargeHistory.date) {
                        let dateDisplayFormatter = DateFormatter()
                        dateDisplayFormatter.dateFormat = "dd MMMM, yyyy"

                        row.keySignal.value = dateDisplayFormatter.string(from: date)
                    }

                    row.valueSignal.value =
                        chargeHistory.amount.fragments.monetaryAmountFragment.monetaryAmount
                        .formattedAmount

                    return section.append(row)
                }

            let moreRow = RowView()
            moreRow.append(
                UILabel(value: L10n.paymentsBtnHistory, style: .brand(.headline(color: .primary)))
            )

            let arrow = Icon(frame: .zero, icon: hCoreUIAssets.chevronRight.image, iconWidth: 20)

            moreRow.append(arrow)

            arrow.snp.makeConstraints { make in make.width.equalTo(20) }

            innerBag += section.append(moreRow)
                .onValue { _ in self.presentingViewController.present(PaymentsHistory()) }

            innerBag += { section.remove(moreRow) }

            return innerBag
        }

        return (section, bag)
    }
}
