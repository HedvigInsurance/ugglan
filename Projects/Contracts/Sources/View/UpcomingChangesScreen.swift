import StoreContainer
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct UpcomingChangesScreen: View {
    let updateDate: String
    let upcomingAgreement: Agreement?
    @PresentableStore var store: ContractStore

    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel

    init(
        updateDate: String,
        upcomingAgreement: Agreement?
    ) {
        self.updateDate = updateDate
        self.upcomingAgreement = upcomingAgreement
    }
    public var body: some View {
        hForm {
            if let upcomingAgreement {
                hSection(upcomingAgreement.displayItems, id: \.displayValue) { item in
                    hRow {
                        HStack {
                            hText(item.displayTitle)
                            Spacer()
                            hText(item.displayValue).foregroundColor(hTextColor.Opaque.secondary)
                        }
                    }
                }
                .withoutHorizontalPadding
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            VStack(spacing: 16) {
                hSection {
                    InfoCard(text: L10n.InsurancesTab.yourInsuranceWillBeUpdatedWithInfo(updateDate), type: .info)
                }
                VStack(spacing: 8) {
                    hSection {
                        hButton.LargeButton(type: .primary) {
                            NotificationCenter.default.post(name: .openChat, object: nil)
                        } content: {
                            hText(L10n.openChat)
                        }

                    }
                    hSection {
                        hButton.LargeButton(type: .ghost) {
                            contractsNavigationVm.insuranceUpdate = nil
                        } content: {
                            hText(L10n.generalCloseButton)
                        }
                    }
                }
            }
        }
    }
}

struct UpcomingChangesScreen_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingChangesScreen(
            updateDate: "DATE",
            upcomingAgreement: .init(
                premium: MonetaryAmount(amount: 0, currency: ""),
                displayItems: [],
                productVariant:
                    ProductVariant(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: "",
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: ""
                    )
            )
        )
    }
}
