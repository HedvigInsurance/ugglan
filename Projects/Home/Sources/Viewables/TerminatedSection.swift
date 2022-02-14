import Apollo
import Claims
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct TerminatedSection { @Inject var client: ApolloClient }

extension TerminatedSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        var titleLabel = MultilineLabel(value: "", style: .brand(.largeTitle(color: .primary)))
        bag += section.append(titleLabel)

        section.appendSpacing(.inbetween)

        client.fetch(query: GraphQL.HomeQuery())
            .onValue { data in
                titleLabel.value = L10n.HomeTab.terminatedWelcomeTitle(data.member.firstName ?? "")
            }

        let subtitleLabel = MultilineLabel(
            value: L10n.HomeTab.terminatedBody,
            style: .brand(.body(color: .secondary))
        )
        bag += section.append(subtitleLabel)

        section.appendSpacing(.top)

        let store: ClaimsStore = self.get()

        let claimButton = Button(
            title: L10n.HomeTab.claimButtonText,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )
        bag += section.append(claimButton)

        bag += claimButton.onTapSignal.onValue {
            store.send(.submitClaims)
        }

        return (section, bag)
    }
}
