import Presentation
import SwiftUI
import hCore
import hCoreUI

struct TravelCertificateProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    var body: some View {
        ProcesssingView(
            isLoading: $vm.isLoading,
            error: $vm.error,
            loadingViewText: L10n.TravelCertificate.generating,
            successViewTitle: L10n.TravelCertificate.travelCertificateReady,
            successViewBody: L10n.TravelCertificate.weHaveSentCopyToYourEmail,
            onErrorCancelAction: {
                vm.store.send(.navigation(.goBack))
            }
        )
        .hSuccessBottomAttachedView {
            bottomSuccessView
        }
    }

    private var bottomSuccessView: some View {
        hSection {
            VStack(spacing: 16) {
                InfoCard(text: L10n.TravelCertificate.downloadRecommendation, type: .info)
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        vm.presentShare()
                    } content: {
                        hText(L10n.TravelCertificate.download)
                    }
                    hButton.LargeButton(type: .ghost) {
                        vm.store.send(.navigation(.dismissCreateTravelCertificate))
                    } content: {
                        hText(L10n.generalCloseButton)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

class ProcessingViewModel: ObservableObject {
    @PresentableStore var store: TravelInsuranceStore
    @Inject private var service: TravelInsuranceClient
    @Published var isLoading = true
    @Published var error: String?
    @Published var downloadUrl: URL?
    init() {
        submit()
    }

    private func submit() {
        Task { @MainActor in
            isLoading = true
            if let startDateViewModel = store.startDateViewModel,
                let whoIsTravelingViewModel = store.whoIsTravelingViewModel
            {
                let dto = TravenInsuranceFormDTO(
                    contractId: startDateViewModel.specification.contractId,
                    startDate: startDateViewModel.date.localDateString,
                    isMemberIncluded: whoIsTravelingViewModel.isPolicyHolderIncluded,
                    coInsured: whoIsTravelingViewModel.policyCoinsuredPersons.compactMap(
                        { .init(fullName: $0.fullName, personalNumber: $0.personalNumber, birthDate: $0.birthDate) }
                    ),
                    email: startDateViewModel.email
                )
                do {
                    async let request = try await self.service.submitForm(dto: dto)
                    async let minimumTime: () = try Task.sleep(nanoseconds: 3_000_000_000)
                    let data = try await [request, minimumTime] as [Any]
                    if let url = data[0] as? URL {
                        downloadUrl = url
                    }
                    AskForRating().askForReview()
                } catch _ {
                    error = L10n.General.errorBody
                }
            }
            isLoading = false
        }
    }

    func presentShare() {
        Task {
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
                    let activityVC = await UIActivityViewController(
                        activityItems: [temporaryFileURL as Any],
                        applicationActivities: nil
                    )

                    let topViewController = await UIApplication.shared.getTopViewController()
                    await topViewController?.present(activityVC, animated: true, completion: nil)
                } catch _ {
                    throw FileError.downloadError
                }
            } catch let exc {
                error = exc.localizedDescription
            }
        }
    }

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
