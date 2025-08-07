import SwiftUI
import hCoreUI

struct CoInsuredSummaryScreen: View {
    @StateObject var summaryVm: QuoteSummaryViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    init(
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel,
        intentViewModel: IntentViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.intentViewModel = intentViewModel

        self._summaryVm = .init(
            wrappedValue: .init(
                contract: [
                    .init(
                        id: "id1",
                        displayName: "display name",
                        exposureName: "exposure name",
                        newPremium: intentViewModel.intent.newCost.montlyNet,
                        currentPremium: intentViewModel.intent.currentCost.montlyNet,
                        documents: [
                            .init(displayName: "display name", url: "", type: .generalTerms)
                        ],
                        onDocumentTap: { document in },
                        displayItems: [
                            .init(title: "title", value: "value")
                        ],
                        insuranceLimits: [],
                        typeOfContract: .seAccident
                    )
                ],
                onConfirmClick: {
                    editCoInsuredNavigation.showProgressScreenWithSuccess = true
                    Task {
                        await intentViewModel.performCoInsuredChanges(
                            commitId: intentViewModel.intent.id
                        )
                    }
                }
            )
        )
    }

    var body: some View {
        QuoteSummaryScreen(vm: summaryVm)
    }
}

#Preview {
    CoInsuredSummaryScreen(
        editCoInsuredNavigation: .init(
            config: .init(
                contract: .init(
                    id: "",
                    exposureDisplayName: "",
                    supportsCoInsured: true,
                    upcomingChangedAgreement: nil,
                    currentAgreement: nil,
                    terminationDate: nil,
                    coInsured: [],
                    firstName: "",
                    lastName: "",
                    ssn: nil
                ),
                preSelectedCoInsuredList: [],
                fromInfoCard: false
            )
        ),
        intentViewModel: .init()
    )
}
