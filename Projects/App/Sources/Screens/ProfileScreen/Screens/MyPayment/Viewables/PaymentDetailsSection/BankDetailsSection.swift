import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL

struct BankDetailsSection {
    @Inject var client: ApolloClient
}

extension BankDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.myPaymentBankRowLabel,
            footer: nil
        )
        let row = KeyValueRow()
        row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += section.append(row)

        let dataSignal = client.watch(query: GraphQL.MyPaymentQuery())
        let noBankAccountSignal = dataSignal.filter {
            $0.bankAccount == nil
        }

        bag += noBankAccountSignal.map {
            _ in L10n.myPaymentNotConnected
        }.bindTo(row.keySignal)

        bag += dataSignal.compactMap {
            $0.bankAccount?.bankName
        }.bindTo(row.keySignal)

        bag += dataSignal.compactMap {
            $0.bankAccount?.descriptor
        }.bindTo(row.valueSignal)

        return (section, bag)
    }
}
