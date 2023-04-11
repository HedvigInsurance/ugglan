import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct BankDetailsSection {
    @Inject var giraffe: hGiraffe
    let urlScheme: String
}

extension BankDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(header: L10n.myPaymentBankRowLabel, footer: nil)
        let row = KeyValueRow()
        row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += section.append(row)

        let dataSignal = giraffe.client.watch(
            query: GiraffeGraphQL.MyPaymentQuery(
                locale: Localization.Locale.currentLocale.asGraphQLLocale()
            )
        )
        let noBankAccountSignal = dataSignal.filter { $0.bankAccount == nil }

        bag += noBankAccountSignal.map { _ in L10n.myPaymentNotConnected }.bindTo(row.keySignal)

        bag += dataSignal.compactMap { $0.bankAccount?.bankName }.bindTo(row.keySignal)

        bag += dataSignal.compactMap { $0.bankAccount?.descriptor }.bindTo(row.valueSignal)

        let myPaymentQuerySignal = giraffe.client.watch(
            query: GiraffeGraphQL.MyPaymentQuery(
                locale: Localization.Locale.currentLocale.asGraphQLLocale()
            ),
            cachePolicy: .returnCacheDataAndFetch
        )

        func addConnectPayment(_ data: GiraffeGraphQL.MyPaymentQuery.Data) -> Disposable {
            let bag = DisposeBag()
            let hasAlreadyConnected = data.payinMethodStatus != .needsSetup
            let buttonText =
                hasAlreadyConnected
                ? L10n.myPaymentDirectDebitReplaceButton : L10n.myPaymentDirectDebitButton

            let paymentSetupRow = RowView(title: buttonText, style: .brand(.headline(color: .link)))

            let setupImageView = UIImageView()
            setupImageView.image =
                hasAlreadyConnected ? hCoreUIAssets.editIcon.image : hCoreUIAssets.circularPlus.image
            setupImageView.tintColor = .brand(.link)

            paymentSetupRow.append(setupImageView)

            bag += section.append(paymentSetupRow).compactMap { section.viewController }
                .onValue { viewController in
                    let setup = PaymentSetup(
                        setupType: hasAlreadyConnected ? .replacement : .initial,
                        urlScheme: self.urlScheme
                    )
                    .journeyThenDismiss

                    viewController.present(
                        setup
                    )
                    .sink()
                }

            bag += { section.remove(paymentSetupRow) }

            return bag
        }

        bag += myPaymentQuerySignal.onValueDisposePrevious { data in let innerBag = bag.innerBag()

            switch data.payinMethodStatus {
            case .pending:
                let pendingRow = RowView()

                innerBag += pendingRow.append(
                    MultilineLabel(
                        value: L10n.myPaymentUpdatingMessage,
                        style: .brand(.footnote(color: .tertiary))
                    )
                )

                section.append(pendingRow)

                innerBag += { section.remove(pendingRow) }

                innerBag += addConnectPayment(data)
            case .active, .needsSetup, .__unknown: innerBag += addConnectPayment(data)
            }

            return innerBag
        }

        return (section, bag)
    }
}
