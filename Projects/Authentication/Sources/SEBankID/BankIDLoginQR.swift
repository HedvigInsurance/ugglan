import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct BankIDLoginQR: View {
    @PresentableStore var store: AuthenticationStore
    @StateObject var vm = BandIDViewModel()

    public init() {}
    public var body: some View {
        Group {
            if vm.isLoading {
                HStack {
                    DotsActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(hBackgroundColor.primary.opacity(0.01))
                .edgesIgnoringSafeArea(.top)
                .useDarkColor
                .transition(.opacity.combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
                .onAppear {
                    vm.onAppear()
                }
            } else {
                hForm {
                    VStack(spacing: 32) {
                        ZStack {
                            if let image = vm.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 140)
                                    .foregroundColor(hTextColor.primary)
                                    .transition(.opacity)
                                    .id(image.pngData()?.count ?? 0)
                            }
                        }
                        .onLongPressGesture(minimumDuration: 3.0) {
                            vm.showAlert = true
                        }
                        .alert(isPresented: $vm.showAlert) {
                            Alert(
                                title: Text(L10n.demoModeStart),
                                message: nil,
                                primaryButton: .cancel(Text(L10n.demoModeCancel)),
                                secondaryButton: .destructive(Text(L10n.logoutAlertActionConfirm)) {
                                    ApplicationContext.shared.$isDemoMode.value = true
                                    store.send(.bankIdQrResultAction(action: .loggedIn))
                                    store.send(.cancel)
                                }
                            )
                        }

                        hSection {
                            VStack(spacing: 0) {
                                hText(L10n.authenticationBankidLoginTitle)
                                    .foregroundColor(hTextColor.primaryTranslucent)
                                hSection {
                                    hText(L10n.authenticationBankidLoginLabel)
                                        .foregroundColor(hTextColor.secondaryTranslucent)
                                        .multilineTextAlignment(.center)
                                }
                                .sectionContainerStyle(.transparent)
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    .padding(.top, UIScreen.main.bounds.size.height / 5.0)
                }
                .hDisableScroll
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 16) {
                            if vm.hasBankIdApp {
                                hButton.LargeButton(type: .primary) {
                                    vm.openBankId()
                                } content: {
                                    HStack(spacing: 8) {
                                        Image(uiImage: hCoreUIAssets.bankIdSmall.image)
                                        hText(L10n.authenticationBankidOpenButton)
                                    }
                                }
                            }

                            hButton.LargeButton(type: .ghost) {
                                store.send(.cancel)
                                store.send(.bankIdQrResultAction(action: .emailLogin))
                            } content: {
                                hText(L10n.BankidMissingLogin.emailButton)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .sectionContainerStyle(.transparent)
                }
                .transition(.opacity.combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
            }
        }
    }
}

class BandIDViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var token: String?
    @Published var image: UIImage?
    @Published var hasBankIdApp = false
    @Published var isLoading = true
    @Published var hasAlreadyOpenedBankId = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        checkIfCanOpenBankId()
        let store: AuthenticationStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .plain()
            .map({ $0.seBankIDState.autoStartToken })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.set(token: value)
            }
            .store(in: &cancellables)

        store.stateSignal
            .plain()
            .map({ $0.seBankIDState.liveQrCodeData })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.set(qrData: value)
            }
            .store(in: &cancellables)
    }

    deinit {
        let store: AuthenticationStore = globalPresentableStoreContainer.get()
        store.send(.cancel)
    }

    func onAppear() {
        let store: AuthenticationStore = globalPresentableStoreContainer.get()
        if store.state.seBankIDState.autoStartToken == nil {
            store.send(.seBankIDStateAction(action: .startSession))
        }
    }

    private func checkIfCanOpenBankId() {
        let bankIdAppTestUrl = URL(
            string:
                "bankid:///"
        )!

        if UIApplication.shared.canOpenURL(bankIdAppTestUrl) {
            hasBankIdApp = true
        }
    }

    func openBankId() {
        guard let token else {
            return
        }
        let urlScheme = Bundle.main.urlScheme ?? ""
        if let url = URL(string: "bankid:///?autostarttoken=\(token)&redirect=\(urlScheme)://bankid") {
            log.info("BANK ID APP started", error: nil, attributes: ["token": token])
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(
                    url,
                    options: [:],
                    completionHandler: nil
                )
            }
        }
    }

    private func set(token: String?) {
        self.token = token
        withAnimation {
            isLoading = token == nil
        }
        guard let token else {
            self.image = nil
            return
        }
        if hasBankIdApp && !hasAlreadyOpenedBankId {
            hasAlreadyOpenedBankId = true
            openBankId()
        }

        withAnimation {
            self.image = generateQRImage(from: "bankid:///?autostarttoken=\(token)")
        }
    }

    private func set(qrData: String?) {
        guard let qrData else {
            self.image = nil
            return
        }
        withAnimation(.snappy) {
            self.image = generateQRImage(from: qrData)
        }
    }

    private func generateQRImage(from url: String) -> UIImage? {
        let data = url.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return nil }

        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)

        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        maskToAlphaFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        let processedImage = UIImage(cgImage: cgImage).withRenderingMode(.alwaysTemplate)
        return processedImage
    }
}

struct BankIDLoginQR_Previews: PreviewProvider {
    static var previews: some View {
        BankIDLoginQR()
    }
}
