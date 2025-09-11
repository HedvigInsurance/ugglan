import Apollo
import Contracts
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct RenewalCardView: View {
    @PresentableStore var store: HomeStore
    @State private var showMultipleAlert = false
    @State private var showFailedToOpenUrlAlert = false
    @State private var document: hPDFDocument?
    let showCoInsured: Bool?

    public init(
        showCoInsured: Bool? = true
    ) {
        self.showCoInsured = showCoInsured
    }

    private func buildSheetButtons(contracts: [HomeContract]) -> [ActionSheet.Button] {
        var buttons = contracts.map { contract in
            ActionSheet.Button.default(Text(contract.displayName)) {
                openDocument(contract)
            }
        }
        buttons.append(ActionSheet.Button.cancel())
        return buttons
    }

    private func openDocument(_ contract: HomeContract) {
        if let draftCertificateUrl = contract.upcomingRenewal?.draftCertificateUrl,
            URL(string: draftCertificateUrl) != nil
        {
            document = hPDFDocument(
                displayName: contract.displayName,
                url: contract.upcomingRenewal?.draftCertificateUrl ?? "",
                type: .unknown
            )
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
                    if $0.upcomingChangedAgreement == nil {
                        return false
                    } else {
                        return !$0.coInsured.isEmpty
                    }
                }), showCoInsured ?? false {
                    InfoCard(
                        text: L10n.contractCoinsuredUpdateInFuture(
                            contract.coInsured.count,
                            contract.upcomingChangedAgreement?.agreementDate?.activeFrom?.localDateToDate?
                                .displayDateDDMMMYYYYFormat
                                ?? ""
                        ),
                        type: .info
                    )
                    .buttons([
                        .init(
                            buttonTitle: L10n.contractViewCertificateButton,
                            buttonAction: {
                                let certificateURL = contract.upcomingChangedAgreement?.certificateUrl
                                openDocument(
                                    HomeContract(
                                        upcomingRenewal: .init(
                                            renewalDate: contract.upcomingChangedAgreement?.agreementDate?.activeFrom,
                                            draftCertificateUrl: certificateURL
                                        ),
                                        displayName: contract.upcomingChangedAgreement?.agreementVariant.productVariant
                                            .displayName ?? ""
                                    )
                                )
                            }
                        )
                    ])
                } else if let upcomingRenewalContract = upcomingRenewalContracts.first,
                    let renewalDate = upcomingRenewalContract.upcomingRenewal?.renewalDate?.localDateToDate
                {
                    if upcomingRenewalContracts.count == 1 {
                        InfoCard(
                            text: L10n.dashboardRenewalPrompterBody(
                                renewalDate.daysBetween(start: Date()) + 1
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
                        let days = upcomingRenewalContracts.first?.upcomingRenewal?.renewalDate?.localDateToDate?
                            .daysBetween(start: Date())
                    {
                        InfoCard(
                            text: days == 1
                                ? L10n.dashboardRenewalPrompterBodyTomorrow
                                : L10n.dashboardRenewalPrompterBody(days + 1),
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
        .detent(item: $document, transitionType: .detent(style: [.large])) { document in
            PDFPreview(document: document)
        }
    }
}

struct RenewalCardView_Previews: PreviewProvider {
    @PresentableStore static var store: HomeStore

    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return RenewalCardView()
            .onAppear {
                let state = MemberContractState.active
                let contract = HomeContract(upcomingRenewal: nil, displayName: "name")
                store.send(.setMemberContractState(state: state, contracts: [contract]))
            }
    }
}
