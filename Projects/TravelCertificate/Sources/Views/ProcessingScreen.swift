import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    var body: some View {
        BlurredProgressOverlay {
            PresentableLoadingStoreLens(
                TravelInsuranceStore.self,
                loadingState: .postTravelInsurance
            ) {
                loadingView
            } error: { error in
                errorView
            } success: {
                successView
            }
        }
        .presentableStoreLensAnimation(.default)
    }

    private var successView: some View {
        ZStack(alignment: .bottom) {
            BackgroundView().ignoresSafeArea()
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.checkmark.image).foregroundColor(hSignalColorNew.greenElement)
                    VStack(spacing: 0) {
                        hText(L10n.TravelCertificate.travelCertificateReady)
                        hText(L10n.TravelCertificate.weHaveSentCopyToYourEmail).foregroundColor(hTextColorNew.secondary)
                    }
                }
                Spacer()
            }
            hSection {
                VStack(spacing: 16) {
                    InfoCard(text: L10n.TravelCertificate.downloadRecommendation, type: .info)
                    VStack(spacing: 8) {
                        hButton.LargeButtonPrimary {
                            Task {
                                await vm.presentShare()
                            }
                        } content: {
                            hText(L10n.TravelCertificate.download)
                        }
                        .trackLoading(TravelInsuranceStore.self, action: .downloadCertificate)

                        hButton.LargeButtonGhost {
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

    private var errorView: some View {
        ZStack {
            BackgroundView().ignoresSafeArea()
            RetryView(
                subtitle: L10n.General.errorBody
            ) {
                vm.store.send(.postTravelInsuranceForm)
            }
            .hRetryAttachToBottom {
                hSection {
                    VStack(spacing: 8) {
                        hButton.LargeButtonPrimary {
                            vm.store.send(.navigation(.openFreeTextChat))
                        } content: {
                            hText(L10n.openChat)
                        }
                        hButton.LargeButtonGhost {
                            vm.store.send(.navigation(.openFreeTextChat))
                        } content: {
                            hText(L10n.generalCloseButton)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private var loadingView: some View {
        VStack {
            hText(L10n.TravelCertificate.generating)
            ProgressView(value: vm.progress)
                .tint(hTextColorNew.primary)
                .frame(width: UIScreen.main.bounds.width * 0.53)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 2).delay(0.5)) {
                            vm.progress = 1
                        }
                    }
                }
        }
    }
}

class ProcessingViewModel: ObservableObject {
    @State var progress: Float = 0
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
                //            store.setLoading(for: .postTravelInsurance)
                //            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                store.setError("ERROR", for: .postTravelInsurance)
                //            }
            }
    }
}
struct BackgroundView: UIViewRepresentable {

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.backgroundColor = .brandNew(.primaryBackground())
    }

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
}
