import SwiftUI
import hCore
import hCoreUI

struct InsuranceEvidenceInputScreen: View {
    @ObservedObject var vm: InsuranceEvidenceInputScreenViewModel

    var body: some View {
        CertificateInputScreen(
            title: L10n.InsuranceEvidence.documentTitle,
            subtitle: L10n.Certificates.verifyEmail,
            isLastScreenInFlow: true,
            elements: [.email],
            vm: .init(
                emailInput: $vm.insuranceEvidenceInput.email,
                state: $vm.state,
                onButtonClick: vm.confirm,
                infoViewClicked: {
                    vm.insuranceEvidenceNavigationViewModel?.isInfoViewPresented = true
                }
            )
        )
        .hWithTooltip
    }
}

@MainActor
class InsuranceEvidenceInputScreenViewModel: ObservableObject {
    weak var insuranceEvidenceNavigationViewModel: InsuranceEvidenceNavigationViewModel!
    @Published var state: ProcessingState = .loading
    @Published var insuranceEvidenceInput = InsuranceEvidenceInput(email: "")
    init(InsuranceEvidenceNavigationViewModel: InsuranceEvidenceNavigationViewModel) {
        self.insuranceEvidenceNavigationViewModel = InsuranceEvidenceNavigationViewModel
        getData()
    }

    private func getData() {
        state = .loading
        Task {
            do {
                let data = try await insuranceEvidenceNavigationViewModel.service.getInitialData()
                insuranceEvidenceInput.email = data.email
                state = .success
            } catch {
                state = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func confirm() {
        insuranceEvidenceNavigationViewModel.router.push(
            InsuranceEvidenceNavigationRouterType.processing(input: insuranceEvidenceInput)
        )
    }
}
