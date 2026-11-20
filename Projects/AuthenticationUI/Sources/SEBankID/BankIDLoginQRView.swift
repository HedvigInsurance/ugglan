import AuthenticationCore
import Combine
import SwiftUI
import hCore
import hCoreUI

public struct BankIDLoginQRView: View {
    @State var vm: BankIDViewModel
    @Environment(NavigationRouter.self) var router

    private var onStartDemoMode: () async -> Void

    /// - Parameter powerOfAttorneyId: Id from a power of attorney link. When set, the person named in that power of
    ///   attorney logs in to the member's account (no email login or demo mode).
    /// - Parameter onCompleted: Called once the login completed, instead of moving the app to the logged in state. For
    ///   a login started while already logged in (switching to a power of attorney), where the caller swaps sessions.
    public init(
        powerOfAttorneyId: String? = nil,
        onCompleted: (() -> Void)? = nil,
        onStartDemoMode: @escaping () async -> Void
    ) {
        _vm = State(initialValue: BankIDViewModel(powerOfAttorneyId: powerOfAttorneyId, onCompleted: onCompleted))
        self.onStartDemoMode = onStartDemoMode
    }

    private var isPowerOfAttorneyLogin: Bool {
        vm.powerOfAttorneyId != nil
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
                            if let qrCode = vm.qrCode {
                                BankIDQRCodeView(qrCode: qrCode)
                                    .accessibilityLabel(L10n.bankidLoginTitle)
                            }
                        }
                        .onLongPressGesture(minimumDuration: 3.0) {
                            if !isPowerOfAttorneyLogin {
                                vm.showAlert = true
                            }
                        }
                        .accessibilityAction(named: Text(L10n.demoModeStart)) {
                            if !isPowerOfAttorneyLogin {
                                vm.showAlert = true
                            }
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
                                // TODO: Localize "Log in with power of attorney" via Lokalise
                                hText(
                                    isPowerOfAttorneyLogin
                                        ? "Log in with power of attorney" : L10n.authenticationBankidLoginTitle
                                )
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

                            if !isPowerOfAttorneyLogin {
                                hButton(
                                    .large,
                                    .ghost,
                                    content: .init(title: L10n.BankidMissingLogin.emailButton)
                                ) {
                                    router.push(AuthenticationRouterType.emailLogin)
                                    vm.cancelLogin()
                                }
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
@Observable
class BankIDViewModel {
    var showAlert: Bool = false
    var token: String?
    var qrCode: BankIDQRCode?
    let hasBankIdApp: Bool
    var isLoading = true
    var hasAlreadyOpenedBankId = false
    let powerOfAttorneyId: String?
    @ObservationIgnored private let onCompleted: (() -> Void)?
    @ObservationIgnored private var seBankIdState: SEBankIDState = .init()
    @ObservationIgnored var authenticationService = AuthenticationService()
    @ObservationIgnored private var observeLoginTask: AnyCancellable?
    @ObservationIgnored var router: NavigationRouter?
    init(powerOfAttorneyId: String? = nil, onCompleted: (() -> Void)? = nil) {
        self.powerOfAttorneyId = powerOfAttorneyId
        self.onCompleted = onCompleted
        hasBankIdApp = BankIDApp.isInstalled
    }

    func onAppear() {
        if seBankIdState.autoStartToken == nil {
            observeLoginTask = Task { @MainActor [weak self] in
                do {
                    try await self?.authenticationService
                        .startSeBankId(powerOfAttorneyId: self?.powerOfAttorneyId) { [weak self] newStatus in
                            DispatchQueue.main.async {
                                switch newStatus {
                                case let .started(code):
                                    self?.set(token: code)
                                case let .pending(qrCode):
                                    self?.set(qrData: qrCode)
                                case .completed:
                                    if let onCompleted = self?.onCompleted {
                                        onCompleted()
                                    } else {
                                        ApplicationState.preserveState(.loggedIn)
                                        ApplicationState.state = .loggedIn
                                    }
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

    func openBankId() {
        guard let token else { return }
        BankIDApp.open(autoStartToken: token)
    }

    private func set(token: String?) {
        self.token = token
        withAnimation {
            isLoading = token == nil
        }
        guard let token else {
            qrCode = nil
            return
        }
        if hasBankIdApp, !hasAlreadyOpenedBankId {
            hasAlreadyOpenedBankId = true
            openBankId()
        }

        withAnimation {
            qrCode = BankIDQRCode(autoStartToken: token)
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
            qrCode = nil
            return
        }
        withAnimation(.snappy(duration: 0.1)) {
            qrCode = BankIDQRCode(data: qrData)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AuthenticationService in AuthenticationService() })
    return BankIDLoginQRView {}
        .environment(NavigationRouter())
}
