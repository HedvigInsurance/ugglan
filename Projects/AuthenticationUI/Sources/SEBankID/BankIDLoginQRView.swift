import AuthenticationCore
import Combine
import SwiftUI
import hCore
import hCoreUI

public struct BankIDLoginQRView: View {
    @State var vm = BankIDViewModel()
    @Environment(NavigationRouter.self) var router
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

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
                    VStack(spacing: .padding32) {
                        ZStack {
                            if let image = vm.image {
                                qrCode(image)
                                    .transition(.opacity)
                                    .id(image.pngData()?.count ?? 0)
                                    .accessibilityLabel(L10n.bankidLoginTitle)
                            }
                        }
                        .onLongPressGesture(minimumDuration: 3.0) {
                            vm.showAlert = true
                        }
                        .accessibilityAction(named: Text(L10n.demoModeStart)) {
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
                        VStack(spacing: .padding16) {
                            if vm.hasBankIdApp {
                                hButton(
                                    .large,
                                    .primary,
                                    content: .init(
                                        title: L10n.authenticationBankidOpenButton,
                                        buttonImage: .init(
                                            image: hCoreUIAssets.bankID.view,
                                            alignment: .leading
                                        )
                                    )
                                ) { vm.openBankId() }
                            }

                            hButton(
                                .large,
                                .ghost,
                                content: .init(title: L10n.BankidMissingLogin.emailButton)
                            ) {
                                router.push(AuthenticationRouterType.emailLogin)
                                vm.cancelLogin()
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

    /// Always drawn dark-on-light, the way scanners expect a code. In dark mode it sits on a light card
    /// matching the form's light background, which also gives the code its quiet zone.
    private func qrCode(_ image: UIImage) -> some View {
        StyledQRCodeView(image: image)
            .frame(width: 180, height: 180)
            .padding(colorScheme == .dark ? .padding16 : 0)
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: .cornerRadiusXL)
                        .fill(hBackgroundColor.primary)
                }
            }
            .colorScheme(.light)
    }
}

@MainActor
@Observable
class BankIDViewModel {
    var showAlert: Bool = false
    var token: String?
    var image: UIImage?
    var hasBankIdApp = false
    var isLoading = true
    var hasAlreadyOpenedBankId = false
    @ObservationIgnored private var seBankIdState: SEBankIDState = .init()
    @ObservationIgnored var authenticationService = AuthenticationService()
    @ObservationIgnored private var observeLoginTask: AnyCancellable?
    @ObservationIgnored var router: NavigationRouter?
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
                                case let .started(code):
                                    self?.set(token: code)
                                case let .pending(qrCode):
                                    self?.set(qrData: qrCode)
                                case .completed:
                                    ApplicationState.preserveState(.loggedIn)
                                    ApplicationState.state = .loggedIn
                                    self?.router?.dismiss()
                                }
                            }
                        }
                } catch {
                    self?.seBankIdState = .init()
                    self?.router?.push(AuthenticationRouterType.error(message: error.localizedDescription))
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
            log.info("BANK ID APP started", error: nil, attributes: nil)
            if UIApplication.shared.canOpenURL(url) {
                Task { await Dependencies.urlOpener.open(url) }
            }
        }
    }

    private func set(token: String?) {
        self.token = token
        withAnimation {
            isLoading = token == nil
        }
        guard let token else {
            image = nil
            return
        }
        if hasBankIdApp, !hasAlreadyOpenedBankId {
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
            image = nil
            return
        }
        withAnimation(.snappy(duration: 0.1)) {
            self.image = StyledQRCode.image(for: qrData, logoFraction: 0, correctionLevel: .low)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AuthenticationService in AuthenticationService() })
    return BankIDLoginQRView {}
        .environment(NavigationRouter())
}
