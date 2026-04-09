import Authentication
import Combine
import Environment
import Foundation
import Market
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct NotLoggedInView: View {
    @ObservedObject var vm: NotLoggedViewModel
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
                        content: .init(title: L10n.bankidLoginTitle),
                        {
                            vm.showLogin = true
                        }
                    )
                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: L10n.marketingGetHedvig),
                        {
                            vm.onOnBoardPressed()
                        }
                    )
                    .accessibilityAddTraits(.isLink)
                }
            }
        }
    }
}

struct NotLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoggedInView(vm: .init())
    }
}

@MainActor
class NotLoggedViewModel: ObservableObject {
    @Published var bootStrapped: Bool = false
    @Published var viewState: ViewState = .loading
    @Published var showLanguagePicker = false
    @Published var showLogin = false
    let router = NavigationRouter()
    var onLoad: () -> Void = {}
    var cancellables = Set<AnyCancellable>()

    init() {
        $bootStrapped
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    self?.viewState = .language
                    self?.onLoad()
                }
            }
            .store(in: &cancellables)

        bootStrapped = true

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
        Dependencies.urlOpener.open(webUrl)
    }

    enum ViewState {
        case loading
        case language
    }
}
