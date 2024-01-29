import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    var body: some View {
        ProcessingView(
            showSuccessScreen: true,
            TravelInsuranceStore.self,
            loading: .postTravelInsurance,
            loadingViewText: L10n.TravelCertificate.generating,
            successViewTitle: L10n.TravelCertificate.travelCertificateReady,
            successViewBody: L10n.TravelCertificate.weHaveSentCopyToYourEmail,
            onErrorCancelAction: {
                vm.store.send(.navigation(.goBack))
            },
            customBottomSuccessView: bottomSuccessView
        )
    }

    private var bottomSuccessView: some View {
        hSection {
            VStack(spacing: 16) {
                InfoCard(text: L10n.TravelCertificate.downloadRecommendation, type: .info)
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        Task {
                            await vm.presentShare()
                        }
                    } content: {
                        hText(L10n.TravelCertificate.download)
                    }
                    .trackLoading(TravelInsuranceStore.self, action: .downloadCertificate)

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

    func presentShare() async {
        store.setLoading(for: .downloadCertificate)
        do {
            guard let url = store.state.downloadURL else {
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
                store.removeLoading(for: .downloadCertificate)
                let topViewController = await UIApplication.shared.getTopViewController()
                await topViewController?.present(activityVC, animated: true, completion: nil)
            } catch _ {
                throw FileError.downloadError
            }
        } catch let exc {
            store.setError(exc.localizedDescription, for: .downloadCertificate)
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
        ProcessingScreen()
            .onAppear {
                let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
                store.setLoading(for: .postTravelInsurance)
                store.setError("error", for: .postTravelInsurance)
            }
    }
}
