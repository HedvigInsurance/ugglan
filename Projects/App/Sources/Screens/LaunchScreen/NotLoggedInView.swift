import AuthenticationUI
import Combine
import Environment
import Foundation
import Market
import SwiftUI
import hCore
import hCoreUI

struct NotLoggedInView: View {
    let vm: NotLoggedViewModel
    init(
        vm: NotLoggedViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        ZStack {
            LoginVideoView().ignoresSafeArea()
            hSection {
                VStack {
                    contentView
                }
                .environment(\.colorScheme, .light)
                .opacity(vm.viewState == .loading ? 0 : 1)
            }
            .sectionContainerStyle(.transparent)
        }
        .modifier(BankIDSandboxToggle())
    }

    @ViewBuilder
    private var contentView: some View {
        switch vm.viewState {
        case .loading:
            EmptyView()
        case .language:
            languageView
        }
    }

    @ViewBuilder
    var languageView: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        vm.showLanguagePicker = true
                    } label: {
                        Localization.Locale.currentLocale.value.icon
                            .padding(.padding8)
                            .accessibilityLabel(L10n.voiceoverSelectLanguage)
                    }
                }
                Spacer()
                VStack {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.bankidLoginTitle)
                    ) { vm.showLogin = true }
                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: L10n.marketingGetHedvig)
                    ) { vm.onOnBoardPressed() }
                    .accessibilityAddTraits(.isLink)
                }
            }
        }
    }
}

private struct BankIDSandboxToggle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if BankIDSandboxState.isAvailable {
            content.onTapGesture(count: 3) { toggle() }
                .accessibilityAddTraits(.isButton)
        } else {
            content
        }
    }

    @MainActor
    private func toggle() {
        BankIDSandboxState.isEnabled.toggle()
        let isEnabled = BankIDSandboxState.isEnabled
        Toasts.shared.displayToastBar(
            toast: .init(
                type: isEnabled ? .attention : .neutral,
                text: "BankID sandbox \(isEnabled ? "on" : "off")"
            )
        )
    }
}

struct NotLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoggedInView(vm: .init())
    }
}

@MainActor
@Observable
class NotLoggedViewModel {
    var viewState: ViewState = .loading
    var showLanguagePicker = false
    var showLogin = false {
        didSet {
            // A power of attorney login only applies to the login it was opened for
            if !showLogin {
                powerOfAttorneyId = nil
            }
        }
    }
    /// Set when the login was opened from a power of attorney link
    var powerOfAttorneyId: String?
    let router = NavigationRouter()
    @ObservationIgnored var onLoad: () -> Void = {}
    @ObservationIgnored var cancellables = Set<AnyCancellable>()

    init() {
        // Deferred one main-actor turn so the owner can set `onLoad` after init.
        Task { @MainActor [weak self] in
            self?.viewState = .language
            self?.onLoad()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openDeeplingLink),
            name: .openDeepLink,
            object: nil
        )
    }

    /// Opens the BankID login for the person named in a power of attorney link.
    func startPowerOfAttorneyLogin(id: String) {
        showLogin = false
        powerOfAttorneyId = id
        showLogin = true
    }

    @objc func openDeeplingLink(_ notification: Notification) {
        if let url = notification.object as? URL {
            if url.relativePath.contains("login-failure") {
                router.push(AuthenticationRouterType.error(message: L10n.authenticationBankidLoginError))
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @MainActor
    func onOnBoardPressed() {
        var webUrl = Environment.current.webBaseURL
        webUrl.appendPathComponent(Localization.Locale.currentLocale.value.webPath)
        webUrl.appendPathComponent(Localization.Locale.currentLocale.value.priceQoutePath)
        webUrl =
            webUrl
            .appending("utm_source", value: "ios")
            .appending("utm_medium", value: "hedvig-app")
            .appending("utm_campaign", value: "se")
        Task { await Dependencies.urlOpener.open(webUrl) }
    }

    enum ViewState {
        case loading
        case language
    }
}
