import SwiftUI
import hCoreUI

struct CoInsuredSummaryScreen: View {
    @StateObject var vm: CoInsuredSummaryViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    init(
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel,
        intentViewModel: IntentViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.intentViewModel = intentViewModel
        self._vm = StateObject(
            wrappedValue: .init(onConfirm: {
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
        QuoteSummaryScreen(vm: vm.summaryVm)
    }
}

class CoInsuredSummaryViewModel: ObservableObject {
    @Published var summaryVm: QuoteSummaryViewModel
    let onConfirm: () -> Void

    init(
        onConfirm: @escaping () -> Void
    ) {
        self.onConfirm = onConfirm
        self.summaryVm = .init(
            contract: [
                .init(
                    id: "id1",
                    displayName: "display name",
                    exposureName: "exposure name",
                    newPremium: .sek(229),
                    currentPremium: .sek(149),
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
                onConfirm()
            }
        )
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
