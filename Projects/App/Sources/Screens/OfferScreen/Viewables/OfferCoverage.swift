import Apollo
import Contracts
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct OfferCoverage {
    @Inject var client: ApolloClient
}

extension OfferCoverage: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 30)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 20

        let bag = DisposeBag()

        stackView.addArrangedSubview(UILabel(value: L10n.offerScreenCoverageTitle, style: TextStyle.brand(.headline(color: .primary)).centerAligned))

        var bodyLabel = MultilineLabel(value: "", style: TextStyle.brand(.body(color: .secondary)).centerAligned)
        bag += stackView.addArranged(bodyLabel)

        bag += client.fetch(query: GraphQL.OfferQuery()).valueSignal.compactMap { $0.insurance.type }.onValue { type in
            switch type {
            case .brf, .studentBrf:
                bodyLabel.value = L10n.offerScreenCoverageBodyBrf
            case .rent, .studentRent:
                bodyLabel.value = L10n.offerScreenCoverageBodyRental
            case .house:
                bodyLabel.value = L10n.offerScreenCoverageBodyHouse
            case .__unknown:
                break
            }
        }

        let perilFragmentsSignal = client.fetch(query: GraphQL.OfferQuery()).valueSignal
            .compactMap { $0.lastQuoteOfMember.asCompleteQuote?.perils.map { $0.fragments.perilFragment } }
            .plain()
            .readable(initial: [])

        bag += stackView.addArranged(PerilCollection(perilFragmentsSignal: perilFragmentsSignal))

        let insurableLimitFragmentsSignal = client.fetch(query: GraphQL.OfferQuery()).valueSignal
            .compactMap { $0.lastQuoteOfMember.asCompleteQuote?.insurableLimits.map { $0.fragments.insurableLimitFragment } }
            .plain()
            .readable(initial: [])

        bag += stackView.addArranged(Spacing(height: 20))

        stackView.addArrangedSubview(UILabel(value: L10n.offerScreenInsuredAmountsTitle, style: TextStyle.brand(.headline(color: .primary)).centerAligned))
        bag += stackView.addArranged(ContractInsurableLimits(insurableLimitFragmentsSignal: insurableLimitFragmentsSignal))

        return (stackView, bag)
    }
}
