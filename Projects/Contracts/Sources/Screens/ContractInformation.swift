import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ContractInformationView: View {
    @PresentableStore var store: ContractStore
    @State private var showChangeInfoAlert = false

    let id: String

    private var changeInfoAlert: SwiftUI.Alert {
        return Alert(
            title: Text(L10n.myHomeChangeAlertTitle),
            message: Text(L10n.myHomeChangeAlertMessage),
            primaryButton: .destructive(Text(L10n.myHomeChangeAlertActionCancel)),
            secondaryButton: .default(Text(L10n.myHomeChangeAlertActionConfirm)) {
                store.send(.goToFreeTextChat)
            }
        )
    }

    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract = contract {
                VStack {
                    if contract.upcomingAgreementDate?.localDateString != nil {
                        hSection {
                            RenewalInformationCard(contract: contract)
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    if let table = contract.currentAgreementsTable {
                        ForEach(table.sections) { section in
                            hSection(section.rows, id: \.title) { row in
                                hRow {
                                    hText(row.title)
                                }
                                .withCustomAccessory({
                                    Spacer()
                                    hText(String(row.value), style: .body)
                                        .foregroundColor(hLabelColor.secondary)
                                        .padding(.trailing, 8)
                                })
                            }
                            .withHeader {
                                hText(
                                    section.title,
                                    style: .headline
                                )
                                .foregroundColor(hLabelColor.secondary)
                            }
                        }
                    }
                    if contract.currentAgreement?.status != .terminated {
                        if hAnalyticsExperiment.movingFlow, contract.showsMovingFlowButton {
                            hSection {
                                hButton.LargeButtonOutlined {
                                    store.send(.goToMovingFlow)
                                } content: {
                                    hText(L10n.HomeTab.editingSectionChangeAddressLabel)
                                }
                            }
                            .sectionContainerStyle(.transparent)
                        } else {
                            hSection {
                                hButton.LargeButtonText {
                                    showChangeInfoAlert = true
                                } content: {
                                    hText(L10n.contractDetailHomeChangeInfo)
                                }
                                .alert(isPresented: $showChangeInfoAlert) {
                                    changeInfoAlert
                                }
                            }
                            .sectionContainerStyle(.transparent)
                        }
                        ChangePeopleView()
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct ChangePeopleView: View {
    @PresentableStore var store: ContractStore

    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: 16) {
                L10n.InsuranceDetailsViewYourInfo.editInsuranceTitle
                    .hText(.title2)
                L10n.InsuranceDetailsViewYourInfo.editInsuranceDescription
                    .hText(.subheadline)
                    .foregroundColor(hLabelColor.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)
                hButton.LargeButtonFilled {
                    store.send(.goToFreeTextChat)
                } content: {
                    L10n.InsuranceDetailsViewYourInfo.editInsuranceButton.hText()
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct RenewalInformationCard: View {
    @PresentableStore var store: ContractStore
    let contract: Contract

    var body: some View {
        VStack {
            hCard(
                titleIcon: hCoreUIAssets.refresh.image,
                title: L10n.InsuranceDetails.updateDetailsSheetTitle,
                bodyText: L10n.InsuranceDetails.AdressUpdateBody.No.address(
                    contract.upcomingAgreementDate?.localDateString ?? ""
                ),
                backgroundColor: hTintColor.lavenderTwo
            ) {
                hButton.SmallButtonOutlined {
                    store.send(
                        .contractDetailNavigationAction(
                            action: .upcomingAgreement(details: contract.upcomingAgreementsTable)
                        )
                    )
                } content: {
                    L10n.InsuranceDetails.addressUpdateButton.hText()
                }
            }
        }
    }
}
