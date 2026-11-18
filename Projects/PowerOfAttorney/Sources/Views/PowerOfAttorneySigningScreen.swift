import SwiftUI
import hCore
import hCoreUI

struct PowerOfAttorneySigningScreen: View {
    @State private var vm: PowerOfAttorneySigningViewModel
    @Environment(NavigationRouter.self) private var router
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    init(user: PowerOfAttorneyUser, level: PowerOfAttorney.Level) {
        _vm = State(initialValue: PowerOfAttorneySigningViewModel(user: user, level: level))
    }

    var body: some View {
        Group {
            switch vm.state {
            case .loading:
                DotsActivityIndicator(.standard)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .useDarkColor
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(L10n.embarkLoading)
            case .waitingForSignature:
                signingView
            case .success:
                // Shown only for a moment, the success screen is pushed on top
                Color.clear
            case let .failed(message):
                failedView(message: message)
            }
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        .onAppear { [vm] in
            vm.startSigning()
        }
        .onDisappear { [vm] in
            vm.cancelSigning()
        }
        .onChange(of: vm.state) { [vm, router] _, state in
            if case let .success(shareUrl) = state {
                router.push(PowerOfAttorneySuccessRouterType.success(user: vm.user, shareUrl: shareUrl))
            }
        }
    }

    private var signingView: some View {
        hForm {
            VStack(spacing: .padding32) {
                ZStack {
                    if let image = vm.qrImage {
                        qrCode(image)
                            .transition(.opacity)
                            .id(image.pngData()?.count ?? 0)
                            // TODO: Localize via Lokalise
                            .accessibilityLabel("BankID QR code")
                    }
                }
                hSection {
                    VStack(spacing: 0) {
                        // TODO: Localize via Lokalise
                        hText("Sign with BankID")
                            .foregroundColor(hTextColor.Translucent.primary)
                        hText(vm.statusText ?? defaultInstruction)
                            .foregroundColor(hTextColor.Translucent.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    if vm.hasBankIdApp {
                        hButton(
                            .large,
                            .primary,
                            content: .init(
                                title: L10n.authenticationBankidOpenButton,
                                buttonImage: .init(image: hCoreUIAssets.bankID.view, alignment: .leading)
                            )
                        ) { [vm] in
                            vm.openBankId()
                        }
                    }
                    hCancelButton {
                        router.pop()
                    }
                }
                .padding(.bottom, .padding16)
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private var defaultInstruction: String {
        // TODO: Localize via Lokalise
        "Open the BankID app on your phone or scan the QR code to sign the power of attorney for \(vm.user.fullName)"
    }

    private func failedView(message: String) -> some View {
        StateView(
            type: .error,
            title: L10n.somethingWentWrong,
            bodyText: message
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(buttonTitle: L10n.generalRetry) { [vm] in
                    vm.startSigning()
                },
                dismissButton: .init(buttonTitle: L10n.generalCancelButton) {
                    router.pop()
                }
            )
        )
        .onAppear {
            // Move VoiceOver focus to the error content, the signing view it replaced is gone
            UIAccessibility.post(notification: .screenChanged, argument: nil)
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
final class PowerOfAttorneySigningViewModel {
    enum SigningState: Equatable {
        case loading
        case waitingForSignature
        case success(shareUrl: URL)
        case failed(message: String)
    }

    let user: PowerOfAttorneyUser
    let level: PowerOfAttorney.Level
    var state: SigningState = .loading
    var qrImage: UIImage?
    /// Text from the backend describing the current signing status, shown instead of the default instruction.
    var statusText: String?
    let hasBankIdApp: Bool
    @ObservationIgnored private var autoStartToken: String?
    @ObservationIgnored private var hasAlreadyOpenedBankId = false
    @ObservationIgnored private var signingTask: Task<Void, Never>?
    @ObservationIgnored private let service = PowerOfAttorneyService()

    init(user: PowerOfAttorneyUser, level: PowerOfAttorney.Level) {
        self.user = user
        self.level = level
        if let bankIdAppTestUrl = URL(string: "bankid:///") {
            hasBankIdApp = UIApplication.shared.canOpenURL(bankIdAppTestUrl)
        } else {
            hasBankIdApp = false
        }
    }

    /// Starts (or restarts) the signing. Does nothing if a signing is already running or has succeeded,
    /// so returning to the screen (e.g. from the share sheet) doesn't start a new one.
    func startSigning() {
        switch state {
        case .success:
            return
        case .loading, .waitingForSignature:
            if let signingTask, !signingTask.isCancelled { return }
        case .failed:
            break
        }
        autoStartToken = nil
        hasAlreadyOpenedBankId = false
        qrImage = nil
        statusText = nil
        withAnimation { state = .loading }
        signingTask = Task { [weak self] in
            await self?.runSigning()
        }
    }

    func cancelSigning() {
        signingTask?.cancel()
        signingTask = nil
    }

    func openBankId() {
        guard let autoStartToken else { return }
        let urlScheme = Bundle.main.urlScheme ?? ""
        guard
            let url = URL(string: "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid"),
            UIApplication.shared.canOpenURL(url)
        else { return }
        Task { await Dependencies.urlOpener.open(url) }
    }

    private func runSigning() async {
        do {
            let session = try await service.startSigning(for: user, level: level)
            try Task.checkCancellation()
            set(autoStartToken: session.autoStartToken, qrData: session.liveQrCodeData)
            for try await status in service.observeSigningStatus(pollUrl: session.pollUrl) {
                switch status {
                case let .pending(qrCode, statusText):
                    set(qrData: qrCode)
                    if let statusText, !statusText.isEmpty {
                        self.statusText = statusText
                    }
                case let .success(shareUrl):
                    withAnimation { state = .success(shareUrl: shareUrl) }
                    return
                case let .failed(message):
                    withAnimation { state = .failed(message: message) }
                    return
                }
            }
            // The stream ended without a final status
            try Task.checkCancellation()
            withAnimation { state = .failed(message: L10n.General.errorBody) }
        } catch is CancellationError {
            // Screen was left, nothing to show
        } catch {
            withAnimation { state = .failed(message: error.localizedDescription) }
        }
    }

    private func set(autoStartToken: String, qrData: String?) {
        self.autoStartToken = autoStartToken
        withAnimation {
            qrImage = StyledQRCode.image(
                for: qrData ?? "bankid:///?autostarttoken=\(autoStartToken)",
                logoFraction: 0,
                correctionLevel: .low
            )
            state = .waitingForSignature
        }
        if hasBankIdApp, !hasAlreadyOpenedBankId {
            hasAlreadyOpenedBankId = true
            openBankId()
        }
    }

    private func set(qrData: String?) {
        guard let qrData else { return }
        withAnimation(.snappy(duration: 0.1)) {
            qrImage = StyledQRCode.image(for: qrData, logoFraction: 0, correctionLevel: .low)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PowerOfAttorneyClient in PowerOfAttorneyClientDemo() })
    return PowerOfAttorneySigningScreen(
        user: .init(id: "1", firstName: "Anna", lastName: "Andersson", ssn: "199001011234"),
        level: .full
    )
    .environment(NavigationRouter())
}
