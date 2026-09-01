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
            .agreementDate
            .activeFrom?
            .localDateToDate?
            .displayDateDDMMMYYYYFormat ?? ""
    }

    var body: some View {
        hForm {
            hSection(agreement.getDisplayItems()) { item in
                switch item.type {
                case let .itemCost(cost):
                    hRow {
                        ItemCostView(itemCost: cost)
                    }
                case let .regular(title, value, subtitle):
                    hRow {
                        VStack(alignment: .leading, spacing: 0) {
                            hText(title)
                            if let subtitle {
                                hText(subtitle, style: .label)
                                    .foregroundColor(hTextColor.Translucent.secondary)
                            }
                        }
                    }
                    .withCustomAccessory {
                        Group {
                            Spacer()
                            if let date = value.localDateToDate?.displayDateDDMMMYYYYFormat {
                                hText(date)
                            } else {
                                ZStack {
                                    hText(value)
                                    hText(" ")
                                }
                            }
                        }
                        .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    .accessibilityElement(children: .combine)
                case .stakeholderItem:
                    EmptyView()
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

#Preview {
    Localization.Locale.currentLocale = .init(.en_SE)
    return UpcomingChangesScreen(
        agreement: .init(
            id: UUID().uuidString,
            basePremium: .sek(200),
            itemCost: .init(premium: .init(gross: .sek(200), net: .sek(200)), discounts: []),
            displayItems: [
                .init(title: "display item 1", value: "display item value 1"),
                .init(title: "display item 2", value: "display item value 2"),
            ],
            productVariant:
                ProductVariant(
                    termsVersion: "",
                    typeOfContract: "",
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
