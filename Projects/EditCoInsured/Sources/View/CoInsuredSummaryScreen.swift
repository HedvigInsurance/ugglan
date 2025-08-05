import SwiftUI
import hCoreUI

struct CoInsuredSummaryScreen: View {
    @ObservedObject var vm: CoInsuredSummaryViewModel

    var body: some View {
        QuoteSummaryScreen(vm: vm.summaryVm)
    }
}

class CoInsuredSummaryViewModel: ObservableObject {
    @Published var summaryVm: QuoteSummaryViewModel

    init() {
        self.summaryVm = .init(contract: [
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
        ])
    }
}

#Preview {
    CoInsuredSummaryScreen(vm: .init())
}
