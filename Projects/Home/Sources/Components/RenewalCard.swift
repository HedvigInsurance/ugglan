import Apollo
import Contracts
import Flow
import Foundation
import Presentation
import SnapKit
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct RenewalCardView: View {
    @PresentableStore var store: HomeStore
    @State private var showMultipleAlert = false
    @State private var showFailedToOpenUrlAlert = false

    public init() {}

    private func buildSheetButtons(contracts: [Contract]) -> [ActionSheet.Button] {
        var buttons = contracts.map { contract in
            ActionSheet.Button.default(Text(contract.displayName)) {
                openDocument(contract)
            }
        }
        buttons.append(ActionSheet.Button.cancel())
        return buttons
    }

    private func dateComponents(from renewalDate: Date) -> DateComponents {
        return Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: renewalDate
        )
    }

    private func openDocument(_ contract: Contract) {
        if let draftCertificateUrl = contract.upcomingRenewal?.draftCertificateUrl,
            let url = URL(string: draftCertificateUrl)
        {
            store.send(.openDocument(contractURL: url))
        } else {
            showFailedToOpenUrlAlert = true
        }
    }

    public var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.upcomingRenewalContracts
            }
        ) { upcomingRenewalContracts in

            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.activeContracts
                }
            ) { contracts in
                if let contract = contracts.first(where: {
                    !($0.upcomingChangedAgreement?.coInsured == $0.currentAgreement?.coInsured)
                }) {

                    InfoCard(
                        text: L10n.contractCoinsuredUpdateInFuture(
                            contract.upcomingChangedAgreement?.coInsured.count ?? 0,
                            contract.upcomingChangedAgreement?.activeFrom?.localDateToDate?.displayDateDDMMMYYYYFormat
                                ?? ""
                        ),
                        type: .info
                    )
                    .buttons([
                        .init(
                            buttonTitle: L10n.contractViewCertificateButton,
                            buttonAction: {
                                let certificateURL = contract.upcomingChangedAgreement?.certificateUrl
                                if let url = URL(string: certificateURL) {
                                    store.send(
                                        .openContractCertificate(
                                            url: url,
                                            title: L10n.myDocumentsInsuranceCertificate
                                        )
                                    )
                                }
                            }
                        )
                    ])
                } else if let upcomingRenewalContract = upcomingRenewalContracts.first {
                    if upcomingRenewalContracts.count == 1 {
                        InfoCard(
                            text: L10n.dashboardRenewalPrompterBody(
                                dateComponents(
                                    from: upcomingRenewalContract.upcomingRenewal!.renewalDate?.localDateToDate!
                                        ?? Date()
                                )
                                .day ?? 0
                            ),
                            type: .info
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.dashboardRenewalPrompterBodyButton,
                                buttonAction: {
                                    openDocument(upcomingRenewalContract)
                                }
                            )
                        ])
                    } else if upcomingRenewalContracts.count > 1,
                        let renewalDate = upcomingRenewalContracts.first?.upcomingRenewal?.renewalDate?.localDateToDate
                    {
                        InfoCard(
                            text: L10n.dashboardMultipleRenewalsPrompterBody(
                                dateComponents(from: renewalDate).day ?? 0
                            ),
                            type: .info
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.dashboardMultipleRenewalsPrompterButton,
                                buttonAction: {
                                    showMultipleAlert = true
                                }
                            )
                        ])
                        .actionSheet(isPresented: $showMultipleAlert) {
                            ActionSheet(
                                title: Text(L10n.dashboardMultipleRenewalsPrompterButton),
                                buttons: buildSheetButtons(contracts: upcomingRenewalContracts)
                            )
                        }

                    }
                }
            }
        }
        .alert(isPresented: $showFailedToOpenUrlAlert) {
            Alert(
                title: Text(L10n.renewalOpenInsuranceTermsErrorTitle),
                message: Text(L10n.renewalOpenInsuranceTermsErrorBody),
                dismissButton: .default(Text(L10n.discountRedeemSuccessButton))
            )
        }
    }
}

struct RenewalCardView_Previews: PreviewProvider {
    @PresentableStore static var store: HomeStore

    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return RenewalCardView()
            .onAppear {
                let state = MemberStateData(state: .active, name: "NAME")
                let octopusContract = OctopusGraphQL.HomeQuery.Data.CurrentMember.ActiveContract(
                    currentAgreement: .init(
                        activeFrom: "",
                        activeTo: "",
                        creationCause: .midtermChange,
                        displayItems: [],
                        premium: .init(amount: 22, currencyCode: .sek),
                        productVariant: .init(
                            perils: [],
                            typeOfContract: "",
                            termsVersion: "",
                            documents: [],
                            displayName: "dispaly name",
                            insurableLimits: []
                        )
                    ),
                    exposureDisplayName: "exposure dispay name",
                    id: "",
                    masterInceptionDate: "",
                    supportsMoving: true,
                    supportsCoInsured: true,
                    upcomingChangedAgreement: .init(
                        activeFrom: "2023-12-10",
                        activeTo: "2024-12-10",
                        creationCause: .renewal,
                        displayItems: [],
                        premium: .init(amount: 22, currencyCode: .sek),
                        productVariant: .init(
                            perils: [],
                            typeOfContract: "",
                            termsVersion: "",
                            documents: [],
                            displayName: "display name",
                            insurableLimits: []
                        )
                    )
                )

                let contract = Home.Contract(contract: octopusContract)
                store.send(.setMemberContractState(state: state, contracts: [contract]))
            }
    }
}
