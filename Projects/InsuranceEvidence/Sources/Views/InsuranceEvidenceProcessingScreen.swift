import SwiftUI
import hCore
import hCoreUI

struct InsuranceEvidenceProcessingScreen: View {
    @ObservedObject var vm: ProcessingViewModel
    @EnvironmentObject var router: Router
    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.TravelCertificate.generating,
            successViewTitle: L10n.TravelCertificate.travelCertificateReady,
            successViewBody: L10n.TravelCertificate.weHaveSentCopyToYourEmail,
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

    private var bottomSuccessView: some View {
        hSection {
            VStack(spacing: 16) {
                InfoCard(text: L10n.TravelCertificate.downloadRecommendation, type: .info)
                VStack(spacing: 8) {
                    ModalPresentationSourceWrapper(
                        content: {
                            hButton.LargeButton(type: .primary) {
                                Task { [weak vm] in
                                    await vm?.presentShare()
                                }
                            } content: {
                                hText(L10n.TravelCertificate.download)
                            }
                        },
                        vm: vm.modalPresentationSourceWrapperViewModel
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    hButton.LargeButton(type: .ghost) {
                        vm.navigation.router.dismiss()
                    } content: {
                        hText(L10n.generalCloseButton)
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
                try await Task.sleep(nanoseconds: 3_000_000_000)
            }
            let results = try await navigation.service.createInsuranceEvidence(input: input)
            try await minimumTime.value
            self.insuranceEvidence = results
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
        "\("Insurance Evidence") \(Date().localDateString)\(".pdf")"
    }

    enum FileError: LocalizedError {
        case urlDoesNotExist
        case downloadError
    }
}

extension UIView {
    func findViewWith(tag: Int) -> UIView? {
        var viewToReturn: UIView?
        for subview in subviews {
            if subview.tag == tag {
                viewToReturn = subview
                break
            }
            if let view = findViewWith(tag: tag) {
                viewToReturn = view
                break
            }
        }
        return viewToReturn
    }
}
