import AuthenticationCore
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
        GeometryReader { proxy in
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
                Spacer(minLength: 0)
                VStack {
                    PublicImportantMessagesView(messages: vm.importantMessages)
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
                // The Hedvig logo is drawn over the middle of this screen, so the cards stay below it.
                .frame(maxHeight: max(proxy.size.height / 2 - .padding16, 0), alignment: .bottom)
            }
        }
        .onAppear {
            vm.startLoadingImportantMessages()
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
        Dependencies.shared.add(
            module: Module { () -> PublicImportantMessagesClient in
                PublicImportantMessagesClientDemo()
            }
        )
        return NotLoggedInView(vm: .init())
    }
}

@MainActor
@Observable
class NotLoggedViewModel {
    var viewState: ViewState = .loading
    var showLanguagePicker = false
    var showLogin = false
    /// Most severe first. Empty while loading and after a failed first load: there is no error state before login.
    var importantMessages: [PublicImportantMessage] = []
    let router = NavigationRouter()
    @ObservationIgnored var onLoad: () -> Void = {}
    @ObservationIgnored var cancellables = Set<AnyCancellable>()
    @ObservationIgnored @Inject private var publicImportantMessagesClient: PublicImportantMessagesClient
    @ObservationIgnored private let appBecameActive: AnyPublisher<Void, Never>
    @ObservationIgnored private let localeChanges: AnyPublisher<Localization.Locale, Never>
    @ObservationIgnored private var importantMessagesTask: Task<Void, Never>?
    @ObservationIgnored private var importantMessagesCancellables = Set<AnyCancellable>()
    var isLoadingImportantMessages: Bool { importantMessagesTask != nil }

    init(
        appBecameActive: AnyPublisher<Void, Never> = NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .map { _ in () }
            .eraseToAnyPublisher(),
        localeChanges: AnyPublisher<Localization.Locale, Never> = Localization.Locale.currentLocale
            .eraseToAnyPublisher()
    ) {
        self.appBecameActive = appBecameActive
        self.localeChanges = localeChanges
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

    /// Loads the important messages the first time the screen appears, then again whenever the app becomes active
    /// or the language changes. Later calls do nothing.
    func startLoadingImportantMessages() {
        guard importantMessagesCancellables.isEmpty else { return }
        loadImportantMessages()
        appBecameActive
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                // A load already running answers for this activation too, such as the one at launch.
                guard let self, importantMessagesTask == nil else { return }
                loadImportantMessages()
            }
            .store(in: &importantMessagesCancellables)
        localeChanges
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadImportantMessages()
            }
            .store(in: &importantMessagesCancellables)
    }

    /// Replaces a load still running, whose answer may be in the previous language. A failure keeps the list shown.
    private func loadImportantMessages() {
        importantMessagesTask?.cancel()
        let client = publicImportantMessagesClient
        importantMessagesTask = Task { [weak self] in
            do {
                let messages = try await client.getMessages()
                guard !Task.isCancelled else { return }
                self?.importantMessages = messages
            } catch {
                guard !Task.isCancelled else { return }
                log.warn("Failed to load the logged-out important messages", error: error, attributes: nil)
            }
            self?.importantMessagesTask = nil
        }
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
