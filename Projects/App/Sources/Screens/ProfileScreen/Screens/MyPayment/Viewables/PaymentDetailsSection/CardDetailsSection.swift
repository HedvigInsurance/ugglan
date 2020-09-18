import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL

struct CardDetailsSection {
    @Inject var client: ApolloClient
}

extension CardDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.myPaymentCardRowLabel,
            footer: nil
        )
        section.isHidden = true

        let row = KeyValueRow()
        row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += section.append(row)

        let dataSignal = client.watch(query: GraphQL.ActivePaymentMethodsQuery())

        bag += dataSignal.map { $0.activePaymentMethods == nil }.bindTo(
            animate: SpringAnimationStyle.lightBounce(),
            section,
            \.animationSafeIsHidden
        )

        bag += dataSignal.compactMap {
            $0.activePaymentMethods?.storedPaymentMethodsDetails.brand?.capitalized
        }.bindTo(row.keySignal)

        bag += dataSignal.compactMap {
            $0.activePaymentMethods?.storedPaymentMethodsDetails.lastFourDigits
        }.map { "**** \($0)" }.bindTo(row.valueSignal)

        return (section, bag)
    }
}
