import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct UpcomingChangesScreen: View {
    let updateDate: String
    let upcomingAgreementsTable: DetailAgreementsTable
    @PresentableStore var store: ContractStore

    fileprivate init(updateDate: String, upcomingAgreementsTable: DetailAgreementsTable) {
        self.updateDate = updateDate
        self.upcomingAgreementsTable = upcomingAgreementsTable
    }
    var body: some View {
        hForm {
            hSection(upcomingAgreementsTable.sections.first?.rows ?? [], id: \.title) { item in
                hRow {
                    HStack {
                        hText(item.title)
                        Spacer()
                        hText(item.value).foregroundColor(hLabelColor.secondary)
                    }
                }
            }
            .withoutHorizontalPadding
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
            upcomingAgreementsTable: .init(
                sections: [.init(title: "TITLE", rows: [.init(title: "TITLE", subtitle: nil, value: "VALUE")])],
                title: "TITLE MORE"
            )
        )
    }
}

extension UpcomingChangesScreen {
    static func journey(contract: Contract) -> some JourneyPresentation {
        return HostingJourney(
            ContractStore.self,
            rootView: UpcomingChangesScreen(
                updateDate: contract.upcomingAgreementDate?.displayDateDotFormat ?? "",
                upcomingAgreementsTable: contract.upcomingAgreementsTable
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
