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
    let id: String
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
                    VStack {
                        if let table = contract.currentAgreementsTable {
                            ForEach(table.sections) { section in
                                hSection(section.rows, id: \.title) { row in
                                    hRow {
                                        hText(row.title, style: .body)
                                    }
                                    .noSpacing()
                                    .verticalPadding(16)
                                    .withCustomAccessory({
                                        Spacer()
                                        hText(String(row.value), style: .body)
                                            .foregroundColor(hTextColorNew.secondary)
                                    })
                                }
                                .withoutHorizontalPadding
                                .sectionContainerStyle(.transparent)
                            }
                        }
                        if contract.currentAgreement?.status != .terminated {
                            hButton.LargeButtonSecondary {
                                //edit info action
                            } content: {
                                hText(L10n.contractEditInfoLabel)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
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
                    .foregroundColor(hTextColorNew.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)
                hButton.LargeButtonPrimary {
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
                    contract.upcomingAgreementDate?.displayDateDotFormat ?? ""
                ),
                backgroundColor: hTintColor.lavenderTwo /* TODO: CHANGE */
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
