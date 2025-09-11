import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct UpcomingChangesScreen: View {
    let agreement: Agreement
    private let date: String
    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel

    init(
        agreement: Agreement
    ) {
        self.agreement = agreement
        self.date =
            agreement
            .agreementDate?
            .activeFrom?
            .localDateToDate?
            .displayDateDDMMMYYYYFormat ?? ""
    }

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                hSection(agreement.displayItems, id: \.displayValue) { item in
                    displayItemView(item)
                }
                if let cost = agreement.itemCost {
                    hRowDivider()
                        .padding(.horizontal, .padding16)
                    ItemCostView(itemCost: cost)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            VStack(spacing: .padding16) {
                hSection {
                    InfoCard(text: L10n.InsurancesTab.yourInsuranceWillBeUpdatedWithInfo(date), type: .info)
                        .buttons([
                            .init(
                                buttonTitle: L10n.openChat,
                                buttonAction: {
                                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                                }
                            )
                        ])
                }
                hSection {
                    VStack(spacing: .padding8) {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.contractViewCertificateButton)
                        ) { [weak contractsNavigationVm] in
                            contractsNavigationVm?.document = hPDFDocument(
                                displayName: L10n.myDocumentsInsuranceCertificate,
                                url: agreement.certificateUrl ?? "",
                                type: .unknown
                            )
                        }

                        hCloseButton {
                            contractsNavigationVm.insuranceUpdate = nil
                        }
                    }
                }
            }
            .padding(.top, .padding16)
        }
        .hWithoutHorizontalPadding([.row, .divider])
        .hFormContentPosition(.compact)
    }

    private func displayItemView(_ item: AgreementDisplayItem) -> some View {
        hRow {
            HStack {
                hText(item.displayTitle)
                Spacer()
                hText(item.displayValue).foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }
}

struct UpcomingChangesScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .init(.en_SE)
        return UpcomingChangesScreen(
            agreement: .init(
                id: UUID().uuidString,
                basePremium: .sek(200),
                itemCost: .init(gross: .sek(200), net: .sek(200), discounts: []),
                displayItems: [
                    .init(title: "display item 1", value: "display item value 1"),
                    .init(title: "display item 2", value: "display item value 2"),
                ],
                agreementVariant: .init(
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
        )
    }
}
