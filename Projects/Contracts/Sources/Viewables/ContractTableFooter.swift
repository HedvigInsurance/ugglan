import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct ContractTableFooter {
    @Inject var client: ApolloClient
    let filter: ContractFilter
}

extension ContractTableFooter: Viewable {
    func materialize(events _: ViewableEvents) -> (FormView, Disposable) {
        let form = FormView()
        let bag = DisposeBag()

        bag += form.append(UpsellingFooter())

        bag += client.watch(
            query: GraphQL.ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
            cachePolicy: .fetchIgnoringCacheData
        )
        .compactMap { $0.contracts }
        .delay(by: 0.5)
        .onValueDisposePrevious { contracts in
            let innerBag = DisposeBag()

            if filter == .active {
                let terminatedContractsCount = contracts.filter { $0.status.asTerminatedStatus == nil }.count

                let section = form.appendSection(
                    header: L10n.InsurancesTab.moreTitle,
                    footer: nil,
                    style: .default
                )

                let terminatedRow = RowView(
                    title: L10n.InsurancesTab.terminatedInsurancesLabel,
                    subtitle: terminatedContractsCount == 1 ?
                        L10n.InsurancesTab.terminatedInsuranceSubtitileSingular :
                        L10n.InsurancesTab.terminatedInsuranceSubtitilePlural(String(terminatedContractsCount))
                )
                terminatedRow.append(hCoreUIAssets.chevronRight.image)

                innerBag += section.append(terminatedRow).compactMap { form.viewController }.onValue { viewController in
                    viewController.present(
                        Contracts(filter: .terminated),
                        options: [.defaults, .largeTitleDisplayMode(.never)]
                    )
                }

                innerBag += {
                    section.removeFromSuperview()
                }
            }

            return innerBag
        }

        return (form, bag)
    }
}
