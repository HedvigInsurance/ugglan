import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct UpcomingChangesScreen: View {
    let updateDate: String
    let upcomingAgreement: Agreement?

    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel

    init(
        updateDate: String,
        upcomingAgreement: Agreement?
    ) {
        self.updateDate = updateDate
        self.upcomingAgreement = upcomingAgreement
    }

    var body: some View {
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
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            VStack(spacing: .padding16) {
                hSection {
                    InfoCard(text: L10n.InsurancesTab.yourInsuranceWillBeUpdatedWithInfo(updateDate), type: .info)
                }
                hSection {
                    VStack(spacing: .padding8) {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.openChat),
                            {
                                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                            }
                        )

                        hCloseButton {
                            contractsNavigationVm.insuranceUpdate = nil
                        }
                    }
                }
            }
            .padding(.top, .padding16)
        }
        .hWithoutHorizontalPadding([.row, .divider])
    }
}

struct UpcomingChangesScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .init(.en_SE)
        return UpcomingChangesScreen(
            updateDate: "DATE",
            upcomingAgreement: .init(
                premium: MonetaryAmount(amount: 0, currency: ""),
                basePremium: .sek(200),
                itemCost: .init(gross: .sek(200), net: .sek(200), discounts: []),
                displayItems: [
                    .init(title: "display item 1", value: "display item value 1"),
                    .init(title: "display item 2", value: "display item value 2"),
                ],
                productVariant:
                    ProductVariant(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: "",
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "",
                        displayNameTier: "Standard",
                        tierDescription: "Vårt mellanpaket med hög ersättning."
                    ),
                addonVariant: []
            )
        )
    }
}
