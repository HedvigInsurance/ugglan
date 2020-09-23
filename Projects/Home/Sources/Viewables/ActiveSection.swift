import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct ActiveSection {
    @Inject var client: ApolloClient
}

extension ActiveSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        let label = MultilineLabel(
            value: "",
            style: .brand(.largeTitle(color: .primary))
        )
        bag += section.append(label)

        client.fetch(query: GraphQL.HomeQuery()).onValue { data in
            label.valueSignal.value = L10n.HomeTab.welcomeTitle(data.member.firstName ?? "")
        }

        section.appendSpacing(.top)

        let button = Button(
            title: L10n.HomeTab.claimButtonText,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )
        bag += section.append(button)

        bag += button.onTapSignal.compactMap { section.viewController }.onValue(Home.openClaimsHandler)

        bag += section.append(ConnectPaymentCard())

        section.appendSpacing(.custom(80))

        bag += section.append(CommonClaimsCollection())

        return (section, bag)
    }
}
