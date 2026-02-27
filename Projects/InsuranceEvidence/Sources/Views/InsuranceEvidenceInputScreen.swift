import SwiftUI
import hCore
import hCoreUI

struct InsuranceEvidenceInputScreen: View {
    @ObservedObject var vm: InsuranceEvidenceInputScreenViewModel
    var body: some View {
        hForm {}
            .sectionContainerStyle(.transparent)
            .hFormTitle(
                title: .init(.small, .heading2, L10n.InsuranceEvidence.documentTitle, alignment: .leading),
                subTitle: .init(.small, .heading2, L10n.Certificates.verifyEmail, alignment: .leading)
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding16) {
                    hSection {
                        VStack(spacing: .padding4) {
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
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.Certificates.createCertificate),
                            {
                                vm.confirm()
                            }
                        )
                    }
                }
            }
            .loadingWithButtonLoading($vm.state)
            .setToolbarLeading {
                ToolbarButtonView(type: ToolbarOptionType.insuranceEvidence, placement: .leading) { _ in
                    vm.insuranceEvidenceNavigationViewModel?.isInfoViewPresented = true
                }
            }
    }
}

@MainActor
class InsuranceEvidenceInputScreenViewModel: ObservableObject {
    weak var insuranceEvidenceNavigationViewModel: InsuranceEvidenceNavigationViewModel!
    @Published var state: ProcessingState = .loading
    @Published var insuranceEvidenceInput = InsuranceEvidenceInput(email: "")
    @Published var focused: Bool?
    init(InsuranceEvidenceNavigationViewModel: InsuranceEvidenceNavigationViewModel) {
        insuranceEvidenceNavigationViewModel = InsuranceEvidenceNavigationViewModel
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
