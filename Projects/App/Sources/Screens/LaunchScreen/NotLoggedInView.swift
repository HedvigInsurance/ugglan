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
    @SwiftUI.Environment(\.verticalSizeClass) private var verticalSizeClass
    @SwiftUI.Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        .onAppear {
            vm.startObservingImportantMessages()
        }
        .onDisappear {
            vm.stopObservingImportantMessages()
        }
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

    /// True when the cards and buttons need the whole height, so the logo drawn over the middle of the screen is hidden
    /// once the launch has finished (`HiddenLogoWhenLoggedOutNeedsTheHeight`).
    static func needsTheWholeHeight(
        verticalSizeClass: UserInterfaceSizeClass?,
        dynamicTypeSize: DynamicTypeSize
    ) -> Bool {
        verticalSizeClass == .compact || dynamicTypeSize.isAccessibilitySize
    }

    @ViewBuilder
    var languageView: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
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
                if verticalSizeClass == .compact {
                    HStack(alignment: .bottom, spacing: .padding16) {
                        messages
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        ViewThatFits(in: .vertical) {
                            buttons
                            ScrollView {
                                buttons
                            }
                            .scrollIndicators(.visible)
                            .scrollIndicatorsFlash(onAppear: true)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                } else {
                    VStack {
                        messages
                        buttons
                    }
                    .frame(maxHeight: maxContentHeight(in: proxy.size.height), alignment: .bottom)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }

    /// Below the logo drawn over the middle of the screen, unless the logo is hidden to make room.
    private func maxContentHeight(in height: CGFloat) -> CGFloat {
        if Self.needsTheWholeHeight(verticalSizeClass: verticalSizeClass, dynamicTypeSize: dynamicTypeSize) {
            return .infinity
        }
        return max(height / 2 - .padding16, 0)
    }

    private var messages: some View {
        PublicImportantMessagesView(messages: vm.importantMessages)
    }

    private var buttons: some View {
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

/// Hides the logo `MainNavigation` draws over the middle of the logged-out screen when that screen needs the whole
/// height (landscape, accessibility text sizes), once the launch animation has finished. The logo is decorative.
struct HiddenLogoWhenLoggedOutNeedsTheHeight: ViewModifier {
    let isLaunching: Bool
    @SwiftUI.Environment(\.verticalSizeClass) private var verticalSizeClass
    @SwiftUI.Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let isHidden =
            !isLaunching
            && NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: verticalSizeClass,
                dynamicTypeSize: dynamicTypeSize
            )
        content
            .opacity(isHidden ? 0 : 1)
            .animation(.easeInOut, value: isHidden)
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
        NotLoggedInView(vm: .init(publicImportantMessagesClient: PublicImportantMessagesClientDemo()))
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
    /// True between `startObservingImportantMessages()` and `stopObservingImportantMessages()`, which the screen calls
    /// as it appears and disappears, logging in included.
    @ObservationIgnored private(set) var isObservingImportantMessages = false
    @ObservationIgnored private let publicImportantMessagesClient: PublicImportantMessagesClient
    @ObservationIgnored private let appBecameActive: AnyPublisher<Void, Never>
    @ObservationIgnored private let localeChanges: AnyPublisher<Localization.Locale, Never>
    @ObservationIgnored private var importantMessagesObservation = Set<AnyCancellable>()
    @ObservationIgnored private var importantMessagesTask: Task<Void, Never>?
    /// Counts the loads started, so an answer to a replaced load is dropped even when it arrives late.
    @ObservationIgnored private var importantMessagesLoads = 0
    /// The language of the latest load that is running or succeeded. Nil when there is none.
    @ObservationIgnored private var importantMessagesLocale: Localization.Locale?
    @ObservationIgnored private var currentLocale: Localization.Locale?

    init(
        publicImportantMessagesClient: PublicImportantMessagesClient = Dependencies.shared.resolve(),
        appBecameActive: AnyPublisher<Void, Never> = NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .map { _ in () }
            .eraseToAnyPublisher(),
        localeChanges: AnyPublisher<Localization.Locale, Never> = Localization.Locale.currentLocale
            .eraseToAnyPublisher()
    ) {
        self.publicImportantMessagesClient = publicImportantMessagesClient
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

    /// Loads the important messages unless they are already loaded or loading in the current language, then reloads
    /// whenever the app becomes active or the language changes.
    func startObservingImportantMessages() {
        guard !isObservingImportantMessages else { return }
        isObservingImportantMessages = true
        localeChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locale in
                guard let self else { return }
                currentLocale = locale
                guard locale != importantMessagesLocale else { return }
                loadImportantMessages(in: locale)
            }
            .store(in: &importantMessagesObservation)
        appBecameActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                // A load already running answers for this activation too, such as the one at launch.
                guard let self, importantMessagesTask == nil, let currentLocale else { return }
                loadImportantMessages(in: currentLocale)
            }
            .store(in: &importantMessagesObservation)
    }

    /// Stops reloading and drops the answer of a load still running.
    func stopObservingImportantMessages() {
        guard isObservingImportantMessages else { return }
        isObservingImportantMessages = false
        importantMessagesObservation.removeAll()
        if let importantMessagesTask {
            importantMessagesTask.cancel()
            self.importantMessagesTask = nil
            importantMessagesLoads += 1
            importantMessagesLocale = nil
        }
    }

    /// Replaces a load still running, whose answer may be in the previous language. A failure keeps the list shown;
    /// the Kotlin read logs it.
    private func loadImportantMessages(in locale: Localization.Locale) {
        importantMessagesTask?.cancel()
        importantMessagesLoads += 1
        let load = importantMessagesLoads
        importantMessagesLocale = locale
        let client = publicImportantMessagesClient
        importantMessagesTask = Task { [weak self] in
            let messages = try? await client.getMessages()
            guard let self, load == importantMessagesLoads else { return }
            importantMessagesTask = nil
            if let messages {
                importantMessages = messages
            } else {
                importantMessagesLocale = nil
            }
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
