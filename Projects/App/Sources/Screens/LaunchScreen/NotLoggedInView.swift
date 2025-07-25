import Authentication
import Combine
import Environment
import Foundation
import Market
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct NotLoggedInView: View {
    @ObservedObject var vm: NotLoggedViewModel
    public init(
        vm: NotLoggedViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        ZStack {
            LoginVideoView().ignoresSafeArea()
            hSection {
                VStack {
                    switch vm.viewState {
                    case .loading:
                        ZStack {}
                    case .language:
                        languageView
                    }
                }
                .environment(\.colorScheme, .light)
                .opacity(vm.viewState == .loading ? 0 : 1)
            }
            .sectionContainerStyle(.transparent)
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
public class NotLoggedViewModel: ObservableObject {
    @PresentableStore var store: MarketStore
    @Published var blurHash: String = ""
    @Published var imageURL: String = ""
    @Published var bootStrapped: Bool = false
    @Published var locale: Localization.Locale = .currentLocale.value
    @Published var title: String = L10n.MarketLanguageScreen.title
    @Published var buttonText: String = L10n.MarketLanguageScreen.continueButtonText
    @Published var viewState: ViewState = .loading
    @Published var showLanguagePicker = false
    @Published var showLogin = false
    let router = Router()
    var onLoad: () -> Void = {}
    var cancellables = Set<AnyCancellable>()

    init() {
        Localization.Locale.currentLocale
            .removeDuplicates()
            .delay(for: 0.1, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.locale = value
                self?.title = L10n.MarketLanguageScreen.title
                self?.buttonText = L10n.MarketLanguageScreen.continueButtonText
            }
            .store(in: &cancellables)

        $bootStrapped
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    self?.viewState = .language
                    self?.onLoad()
                }
            }
            .store(in: &cancellables)

        self.bootStrapped = true

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
        UIApplication.shared.open(webUrl)

    }

    enum ViewState {
        case loading
        case language
    }
}
