import SwiftUI
import hCore
import hCoreUI

struct TravelCertificateProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    @EnvironmentObject var router: Router
    @EnvironmentObject var startDateViewModel: StartDateViewModel
    @EnvironmentObject var whoIsTravelingViewModel: WhoIsTravelingViewModel

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
        .task { [weak vm] in
            vm?.whoIsTravelingViewModel = whoIsTravelingViewModel
            vm?.startDateViewModel = startDateViewModel
            vm?.submit()
        }
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
                        router.dismiss()
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
    var service = TravelInsuranceService()
    @Published var viewState: ProcessingState = .loading
    @Published var isLoading = true
    @Published var error: String?
    @Published var downloadUrl: URL?
    weak var whoIsTravelingViewModel: WhoIsTravelingViewModel?
    weak var startDateViewModel: StartDateViewModel?
    var modalPresentationSourceWrapperViewModel = ModalPresentationSourceWrapperViewModel()
    init() {}

    func submit() {
        Task { @MainActor in
            isLoading = true
            viewState = .loading
            if let startDateViewModel = startDateViewModel,
                let whoIsTravelingViewModel = whoIsTravelingViewModel
            {
                let dto = TravelInsuranceFormDTO(
                    contractId: startDateViewModel.specification.contractId,
                    startDate: startDateViewModel.date.localDateString,
                    isMemberIncluded: whoIsTravelingViewModel.isPolicyHolderIncluded,
                    coInsured: whoIsTravelingViewModel.policyCoinsuredPersons.compactMap(
                        { .init(fullName: $0.fullName, personalNumber: $0.personalNumber, birthDate: $0.birthDate) }
                    ),
                    email: startDateViewModel.email
                )
                do {
                    let minimumTime = Task {
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                    }
                    let url = try await self.service.submitForm(dto: dto)
                    try await minimumTime.value

                    downloadUrl = url
                    viewState = .success
                    AskForRating().askForReview()
                } catch _ {
                    viewState = .error(errorMessage: L10n.General.errorBody)
                    error = L10n.General.errorBody
                }
            }
            isLoading = false
        }
    }

    @MainActor
    func presentShare() async {
        do {
            guard let url = downloadUrl else {
                throw FileError.urlDoesNotExist
            }
            do {
                let data = try Data(contentsOf: url)
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
        } catch let exc {
            error = exc.localizedDescription
        }
    }

    func present(activity: UIActivityViewController) {

    }
    @MainActor
    var fileName: String {
        "\("Travel Insurance Certificate") \(Date().localDateString)\(".pdf")"
    }

    enum FileError: LocalizedError {
        case urlDoesNotExist
        case downloadError
    }
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelCertificateProcessingScreen()
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
