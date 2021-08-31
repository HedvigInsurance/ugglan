import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractTableFooter {
    @Inject var client: ApolloClient
    let filter: ContractFilter
    @PresentableStore var store: ContractStore
}

extension ContractTableFooter: Viewable {
    func materialize(events _: ViewableEvents) -> (FormView, Disposable) {
        let form = FormView()
        let bag = DisposeBag()

        bag += form.append(UpsellingFooter())

        bag +=
            store.stateSignal.atOnce().onValueDisposePrevious { state in
                let innerBag = DisposeBag()
                
                let terminatedContractsCount = state.contracts.filter { $0.currentAgreement?.status == .terminated }
                    .count
                let activeContractsCount = state.contracts.filter { $0.currentAgreement?.status == .active }
                    .count

                if filter.displaysActiveContracts, terminatedContractsCount > 0,
                    activeContractsCount > 0
                {
                    let section = form.appendSection(
                        header: L10n.InsurancesTab.moreTitle,
                        footer: nil,
                        style: .default
                    )

                    let terminatedRow = RowView(
                        title: L10n.InsurancesTab.terminatedInsurancesLabel,
                        subtitle: terminatedContractsCount == 1
                            ? L10n.InsurancesTab.terminatedInsuranceSubtitileSingular
                            : L10n.InsurancesTab.terminatedInsuranceSubtitilePlural(
                                String(terminatedContractsCount)
                            )
                    )
                    terminatedRow.append(hCoreUIAssets.chevronRight.image)

                    innerBag += section.append(terminatedRow).compactMap { form.viewController }
                        .onValue { viewController in
                            innerBag +=
                                viewController.present(
                                    Contracts(filter: .terminated(ifEmpty: .none)),
                                    options: [
                                        .defaults,
                                        .largeTitleDisplayMode(.never),
                                    ]
                                )
                                .onValue { _ in

                                }
                        }

                    innerBag += { section.removeFromSuperview() }
                }

                return innerBag
            }

        return (form, bag)
    }
}
