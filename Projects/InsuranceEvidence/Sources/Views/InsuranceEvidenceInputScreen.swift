import SwiftUI
import hCore
import hCoreUI

struct InsuranceEvidenceInputScreen: View {
    @ObservedObject var vm: InsuranceEvidenceInputScreenViewModel
    var body: some View {
        hForm {}
            .sectionContainerStyle(.transparent)
            .hFormTitle(
                title: .init(.small, .heading2, "Insurance evidence", alignment: .leading),
                subTitle: .init(.small, .heading2, "Please verify your email address", alignment: .leading)
            )
            .hFormAttachToBottom {
                VStack(spacing: 16) {
                    hSection {
                        VStack(spacing: 4) {
                            hFloatingTextField(
                                masking: .init(type: .email),
                                value: $vm.insuranceEvidenceInput.email,
                                equals: $vm.focused,
                                focusValue: true,
                                placeholder: L10n.emailRowTitle
                            )
                        }
                    }
                    hSection {
                        hButton.LargeButton(type: .primary) {
                            vm.confirm()
                        } content: {
                            hText("Send certificate")
                        }
                    }
                }
            }
            .loadingWithButtonLoading($vm.state)
    }
}

@MainActor
class InsuranceEvidenceInputScreenViewModel: ObservableObject {
    weak var insuranceEvidenceNavigationViewModel: InsuranceEvidenceNavigationViewModel!
    @Published var state: ProcessingState = .loading
    @Published var insuranceEvidenceInput = InsuranceEvidenceInput(email: "")
    @Published var focused: Bool?
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
