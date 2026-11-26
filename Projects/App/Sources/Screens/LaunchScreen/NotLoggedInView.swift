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
    @SwiftUI.Environment(\.scenePhase) private var scenePhase
    @State private var locale = Localization.Locale.currentLocale.value

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
        .onReceive(Localization.Locale.currentLocale) { locale = $0 }
        // Nil while the app is not active, so the app becoming active reloads once, at launch too.
        .task(id: scenePhase == .active ? locale : nil) {
            guard scenePhase == .active else { return }
            await vm.loadImportantMessages()
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

    static func needsTheWholeHeight(
        verticalSizeClass: UserInterfaceSizeClass?,
        dynamicTypeSize: DynamicTypeSize,
        contentFitsTheBottomHalf: Bool
    ) -> Bool {
        verticalSizeClass == .compact || dynamicTypeSize.isAccessibilitySize || !contentFitsTheBottomHalf
    }

    var languageView: some View {
        GeometryReader { proxy in
            if verticalSizeClass == .compact {
                VStack(spacing: 0) {
                    languageButton
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
                }
            } else {
                ViewThatFits(in: .vertical) {
                    if !dynamicTypeSize.isAccessibilitySize {
                        // Leaves the top half to the logo `MainNavigation` draws over the middle of the screen.
                        cardsAndButtons
                            .padding(.top, proxy.size.height / 2 + .padding16)
                            .overlay(alignment: .top) { languageButton }
                            .onAppear { vm.onContentFitsTheBottomHalf(true) }
                    }
                    VStack(spacing: 0) {
                        languageButton
                        cardsAndButtons
                    }
                    .onAppear { vm.onContentFitsTheBottomHalf(false) }
                    VStack(spacing: 0) {
                        languageButton
                        VStack {
                            messages
                            buttons
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .onAppear { vm.onContentFitsTheBottomHalf(false) }
                }
            }
        }
    }

    private var languageButton: some View {
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
    }

    /// At their natural height, so `ViewThatFits` picks the scrolling layout rather than scroll the cards here.
    private var cardsAndButtons: some View {
        VStack {
            messages
            buttons
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: .infinity, alignment: .bottom)
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

/// Hides the logo `MainNavigation` draws over the logged-out screen when the screen needs the whole height.
struct HiddenLogoWhenLoggedOutNeedsTheHeight: ViewModifier {
    let isLaunching: Bool
    let contentFitsTheBottomHalf: Bool
    @SwiftUI.Environment(\.verticalSizeClass) private var verticalSizeClass
    @SwiftUI.Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let isHidden =
            !isLaunching
            && NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: verticalSizeClass,
                dynamicTypeSize: dynamicTypeSize,
                contentFitsTheBottomHalf: contentFitsTheBottomHalf
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
    /// There is no error state before login: a failed first load shows nothing.
    var importantMessages: [PublicImportantMessage] = []
    /// Tells the owner, which draws the logo, whether the cards and buttons fit below it.
    @ObservationIgnored var onContentFitsTheBottomHalf: (Bool) -> Void = { _ in }
    let router = NavigationRouter()
    @ObservationIgnored var onLoad: () -> Void = {}
    @ObservationIgnored var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private let publicImportantMessagesClient: PublicImportantMessagesClient

    init(publicImportantMessagesClient: PublicImportantMessagesClient = Dependencies.shared.resolve()) {
        self.publicImportantMessagesClient = publicImportantMessagesClient
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

    /// A failure keeps the list shown; the Kotlin read logs it. The answer to a cancelled load is dropped, as it may be
    /// in the previous language.
    func loadImportantMessages() async {
        guard let messages = try? await publicImportantMessagesClient.getMessages(), !Task.isCancelled else { return }
        importantMessages = messages
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
