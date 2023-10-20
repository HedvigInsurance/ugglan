import Apollo
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
    
    public var hasActiveInfoCard: Bool {
        if RenewalCardModel().showRenewalCard {
            return true
        }
        return false
    }
    
    struct RenewalCardModel {
        var showRenewalCard: Bool = false
        var renewalDate: Date = Date()
        var contracts: [Contract]
        
        init() {
            let homeStore: HomeStore = globalPresentableStoreContainer.get()
            let contracts = homeStore.state.upcomingRenewalContracts
            
            self.contracts = contracts
            
            if contracts.count > 1,
               contracts.allSatisfy({ contract in
                   contract.upcomingRenewal?.renewalDate == contracts.first?.upcomingRenewal?.renewalDate
               }), let renewalDate = contracts.first?.upcomingRenewal?.renewalDate?.localDateToDate
            {
                self.showRenewalCard = true
                self.renewalDate = renewalDate
            }
        }
    }
    
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
        VStack {
            if RenewalCardModel().showRenewalCard {
                InfoCard(
                    text: L10n.dashboardMultipleRenewalsPrompterBody(
                        dateComponents(from: RenewalCardModel().renewalDate).day ?? 0
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
                        buttons: buildSheetButtons(contracts: RenewalCardModel().contracts)
                    )
                }
            } else {
                VStack(spacing: 16) {
                    ForEach(RenewalCardModel().contracts, id: \.displayName) { contract in
                        let renewalDate = contract.upcomingRenewal?.renewalDate?.localDateToDate ?? Date()
                        InfoCard(
                            text: L10n.dashboardRenewalPrompterBody(
                                dateComponents(from: renewalDate).day ?? 0
                            ),
                            type: .info
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.dashboardMultipleRenewalsPrompterButton,
                                buttonAction: {
                                    openDocument(contract)
                                }
                            )
                        ])
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
                            insurableLimits: [],
                            highlights: [],
                            faq: []
                        )
                    ),
                    exposureDisplayName: "exposure dispay name",
                    id: "",
                    masterInceptionDate: "",
                    supportsMoving: true,
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
                            insurableLimits: [],
                            highlights: [],
                            faq: []
                        )
                    )
                )
                
                let contract = Home.Contract(contract: octopusContract)
                store.send(.setMemberContractState(state: state, contracts: [contract]))
            }
    }
}
