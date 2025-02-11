import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct BankIDLoginQRView: View {
    @StateObject var vm = BankIDViewModel()
    @EnvironmentObject var router: Router
    @EnvironmentObject var otpVM: OTPState

    private var onStartDemoMode: () async -> Void
    public init(onStartDemoMode: @escaping () async -> Void) {
        self.onStartDemoMode = onStartDemoMode
    }
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
            } else {
                hForm {
                    VStack(spacing: 32) {
                        ZStack {
                            if let image = vm.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 140)
                                    .foregroundColor(hTextColor.Opaque.primary)
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
                                    Task {
                                        await onStartDemoMode()
                                        router.dismiss()
                                        ApplicationState.preserveState(.loggedIn)
                                        ApplicationState.state = .loggedIn
                                    }
                                }
                            )
                        }

                        hSection {
                            VStack(spacing: 0) {
                                hText(L10n.authenticationBankidLoginTitle)
                                    .foregroundColor(hTextColor.Translucent.primary)
                                hSection {
                                    hText(L10n.authenticationBankidLoginLabel)
                                        .foregroundColor(hTextColor.Translucent.secondary)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .sectionContainerStyle(.transparent)
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    .padding(.top, UIScreen.main.bounds.size.height / 5.0)
                }
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 16) {
                            if vm.hasBankIdApp {
                                hButton.LargeButton(type: .primary) {
                                    vm.openBankId()
                                } content: {
                                    HStack(spacing: 8) {
                                        Image(uiImage: hCoreUIAssets.bankID.image)
                                        hText(L10n.authenticationBankidOpenButton)
                                    }
                                }
                            }

                            hButton.LargeButton(type: .ghost) {
                                router.push(AuthentificationRouterType.emailLogin)
                                vm.cancelLogin()
                            } content: {
                                hText(L10n.BankidMissingLogin.emailButton)
                            }
                        }
                        .padding(.bottom, .padding16)
                    }
                    .sectionContainerStyle(.transparent)
                }
                .transition(.opacity.combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
            }
        }
        .onAppear {
            vm.router = router
            vm.onAppear()
        }
    }
}

@MainActor
class BankIDViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var token: String?
    @Published var image: UIImage?
    @Published var hasBankIdApp = false
    @Published var isLoading = true
    @Published var hasAlreadyOpenedBankId = false
    private var seBankIdState: SEBankIDState = .init()
    var authenticationService = AuthenticationService()
    private var cancellables = Set<AnyCancellable>()
    private var observeLoginTask: AnyCancellable?
    var router: Router?
    init() {
        checkIfCanOpenBankId()
    }

    func onAppear() {
        if seBankIdState.autoStartToken == nil {
            observeLoginTask = Task { @MainActor [weak self] in
                do {
                    try await self?.authenticationService
                        .startSeBankId { [weak self] newStatus in
                            DispatchQueue.main.async {
                                switch newStatus {
                                case .started(let code):
                                    self?.set(token: code)
                                case .pending(let qrCode):
                                    self?.set(qrData: qrCode)
                                case .completed:
                                    ApplicationState.preserveState(.loggedIn)
                                    ApplicationState.state = .loggedIn
                                    self?.router?.dismiss()
                                }
                            }
                        }
                } catch let error {
                    self?.seBankIdState = .init()
                    self?.router?.push(AuthentificationRouterType.error(message: error.localizedDescription))
                }
            }
            .eraseToAnyCancellable()
        }
    }

    func cancelLogin() {
        observeLoginTask?.cancel()
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

    deinit {
        Task { @MainActor [weak self] in
            self?.observeLoginTask?.cancel()
        }
    }

    @MainActor
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
        Dependencies.shared.add(module: Module { () -> AuthenticationService in AuthenticationService() })
        return BankIDLoginQRView {}
            .environmentObject(Router())
    }
}

public enum AuthentificationRouterType: Hashable {
    case emailLogin
    case otpCodeEntry
    case error(message: String)
}

extension AuthentificationRouterType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .emailLogin:
            return .init(describing: OTPEntryView.self)
        case .otpCodeEntry:
            return .init(describing: OTPCodeEntryView.self)
        case .error:
            return .init(describing: LoginErrorView.self)
        }
    }
}
