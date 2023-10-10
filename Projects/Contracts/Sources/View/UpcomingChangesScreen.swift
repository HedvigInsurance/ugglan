import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct UpcomingChangesScreen: View {
    let updateDate: String
    let upcomingAgreement: Agreement?
    @PresentableStore var store: ContractStore
    
    fileprivate init(
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
                            hText(item.displayValue).foregroundColor(hLabelColor.secondary)
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
                            store.send(.contractDetailNavigationAction(action: .dismissUpcomingChanges))
                            store.send(.goToFreeTextChat)
                        } content: {
                            hText(L10n.openChat)
                        }
                        
                    }
                    hSection {
                        hButton.LargeButton(type: .ghost) {
                            store.send(.contractDetailNavigationAction(action: .dismissUpcomingChanges))
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
                        highlights: [],
                        FAQ: [],
                        displayName: ""
                    )
            )
        )
    }
}

extension UpcomingChangesScreen {
    static func journey(contract: Contract) -> some JourneyPresentation {
        return HostingJourney(
            ContractStore.self,
            rootView: UpcomingChangesScreen(
                updateDate: contract.upcomingChangedAgreement?.activeFrom ?? "",
                upcomingAgreement: contract.upcomingChangedAgreement
            ),
            style: .detented(.large),
            options: [.largeNavigationBar]
        ) { action in
            if case .contractDetailNavigationAction(action: .dismissUpcomingChanges) = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.InsuranceDetails.updateDetailsSheetTitle)
    }
}
