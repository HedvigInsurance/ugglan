import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

import SwiftUI

struct ContractInformationView: View {
    @PresentableStore var store: ContractStore
    @State private var showChangeInfoAlert = false
    
    let contract: Contract
    
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
        VStack {
            if contract.upcomingAgreementDate?.localDateString != nil {
                hSection {
                    RenewalInformationCard(contract: contract)
                }.sectionContainerStyle(.transparent)
            }
            if let table = contract.currentAgreementsTable {
                ForEach(table.sections) { section in
                    hSection(section.rows, id: \.title) { row in
                        hRow {
                            hText(row.title)
                        }.withCustomAccessory({
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
            if contract.currentAgreement.status != .terminated {
                if Localization.Locale.currentLocale.market == .se {
                    if contract.showsMovingFlowButton {
                        hSection {
                            hButton.LargeButtonOutlined {
                                store.send(.goToMovingFlow)
                            } content: {
                                hText(L10n.HomeTab.editingSectionChangeAddressLabel)
                            }
                        }.sectionContainerStyle(.transparent)
                    }
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
                    }.sectionContainerStyle(.transparent)
                }
            }
        }.padding(.bottom, 20)
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
                )
            ) {
                hButton.SmallButtonOutlined {
                    store.send(.contractDetailNavigationAction(action: .upcomingAgreement(details: contract.upcomingAgreementsTable)))
                } content: {
                    L10n.InsuranceDetails.addressUpdateButton.hText()
                }
            }
        }
    }
}
