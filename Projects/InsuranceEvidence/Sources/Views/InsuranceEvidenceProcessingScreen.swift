import SwiftUI
import hCore
import hCoreUI

struct InsuranceEvidenceProcessingScreen: View {
    @ObservedObject var vm: ProcessingViewModel
    @EnvironmentObject var router: NavigationRouter
    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.Certificates.generating,
            successViewTitle: L10n.Certificates.emailSent,
            successViewBody: L10n.InsuranceEvidence.emailSentDescription,
            state: $vm.viewState
        )
        .hSuccessBottomAttachedView {
            bottomSuccessView
        }
        .hStateViewButtonConfig(
            .init(
                actionButton: nil,
                actionButtonAttachedToBottom: nil,
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: {
                        router.pop()
                    }
                )
            )
        )
    }

    @ViewBuilder
    private var bottomSuccessView: some View {
        hSection {
            VStack(spacing: .padding16) {
                VStack(spacing: .padding8) {
                    ModalPresentationSourceWrapper(
                        content: {
                            hButton(
                                .large,
                                .primary,
                                content: .init(title: L10n.Certificates.download),
                                {
                                    Task { [weak vm] in
                                        await vm?.presentShare()
                                    }
                                }
                            )
                        },
                        vm: vm.modalPresentationSourceWrapperViewModel
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    hCloseButton {
                        vm.navigation.router.dismiss()
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

@MainActor
class ProcessingViewModel: ObservableObject {
    fileprivate weak var navigation: InsuranceEvidenceNavigationViewModel!
    fileprivate var viewState: ProcessingState = .loading
    private let input: InsuranceEvidenceInput
    fileprivate let modalPresentationSourceWrapperViewModel = ModalPresentationSourceWrapperViewModel()
    @Published var insuranceEvidence: InsuranceEvidence?

    init(input: InsuranceEvidenceInput, navigation: InsuranceEvidenceNavigationViewModel) {
        self.input = input
        self.navigation = navigation
        Task {
            await submit()
        }
    }

    func submit() async {
        viewState = .loading
        do {
            let minimumTime = Task {
                try await Task.sleep(seconds: 3)
            }
            let results = try await navigation.service.createInsuranceEvidence(input: input)
            try await minimumTime.value
            insuranceEvidence = results
            viewState = .success
        } catch {
            viewState = .error(errorMessage: error.localizedDescription)
        }
    }

    @MainActor
    func presentShare() async {
        do {
            guard let url = URL(string: insuranceEvidence?.url) else {
                throw FileError.urlDoesNotExist
            }
            do {
                let data = try await URLSession.shared.data(from: url).0
                let temporaryFolder = FileManager.default.temporaryDirectory
                let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
                do {
                    try? FileManager.default.removeItem(at: temporaryFileURL)
                    try data.write(to: temporaryFileURL)
                } catch {
                    throw FileError.downloadError
                }
                let activityVC = UIActivityViewController(
                    activityItems: [temporaryFileURL as Any],
                    applicationActivities: nil
                )

                modalPresentationSourceWrapperViewModel.present(activity: activityVC)
            } catch _ {
                throw FileError.downloadError
            }
        } catch {}
    }

    var fileName: String {
        "\(L10n.InsuranceEvidence.documentTitle) \(Date().localDateString)\(".pdf")"
    }

    enum FileError: LocalizedError {
        case urlDoesNotExist
        case downloadError
    }
}
