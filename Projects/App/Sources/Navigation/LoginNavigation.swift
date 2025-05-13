import AVKit
import Apollo
import Authentication
import Combine
import Environment
import Foundation
import Market
import PresentableStore
import Profile
import SwiftUI
import hCore
import hCoreUI

struct LoginNavigation: View {
    @ObservedObject var vm: NotLoggedViewModel
    @StateObject private var router = Router()
    @StateObject private var otpState = OTPState()
    var body: some View {
        RouterHost(router: router, options: .navigationBarHidden, tracking: LoginDetentType.notLoggedIn) {
            NotLoggedInView(vm: vm)
        }
        .detent(presented: $vm.showLanguagePicker, style: [.height]) {
            LanguagePickerView {
                let store: ProfileStore = globalPresentableStoreContainer.get()
                store.send(.updateLanguage)
                vm.showLanguagePicker = false
            } onCancel: {
                vm.showLanguagePicker = false
            }
            .navigationTitle(L10n.loginLanguagePreferences)
            .embededInNavigation(
                options: [.navigationType(type: .large)],
                tracking: LoginDetentType.languagePicker
            )
        }
        .detent(presented: $vm.showLogin, style: [.large]) {
            Group {
                BankIDLoginQRView {
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    await store.sendAsync(.setIsDemoMode(to: true))
                    ApolloClient.initAndRegisterClient()
                }
            }
            .environmentObject(otpState)
            .withDismissButton()
            .routerDestination(for: AuthentificationRouterType.self) { type in
                switch type {
                case .emailLogin:
                    OTPEntryView()
                        .environmentObject(otpState)
                        .withDismissButton()
                case .otpCodeEntry:
                    OTPCodeEntryView()
                        .environmentObject(otpState)
                        .withDismissButton()
                case let .error(message):
                    LoginErrorView(message: message)
                }
            }
            .embededInNavigation(tracking: Localization.Locale.currentLocale.value.code)
        }
    }
}

private enum LoginDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .notLoggedIn:
            return .init(describing: NotLoggedInView.self)
        case .languagePicker:
            return .init(describing: LanguagePickerView.self)
        }
    }

    case notLoggedIn
    case languagePicker
}

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
                        Image(uiImage: Localization.Locale.currentLocale.value.icon)
                            .padding(.padding8)
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
                router.push(AuthentificationRouterType.error(message: L10n.authenticationBankidLoginError))
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

struct LoginVideoView: UIViewRepresentable {

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LoginVideoView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
}

private class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Load the resource
        let fileUrl = Bundle.main.url(forResource: "9x16_pillow", withExtension: "mp4")!

        // Setup the player
        let player = AVPlayer(playerItem: AVPlayerItem(url: fileUrl))

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        // Setup looping
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {}

        // Start the movie
        player.playImmediately(atRate: 1)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterForeground(notification:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

    }
    var reversed = false

    @objc
    func didEnterForeground(notification: Notification) {
        playerLayer.player?.play()
    }
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        if let view = self.snapshotView(afterScreenUpdates: false) {
            self.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            UIView.animate(withDuration: 0.1, delay: 0.1) {
                view.alpha = 0
            } completion: { finished in
                view.removeFromSuperview()
            }
            if !reversed {
                playerLayer.player?.playImmediately(atRate: -1)
                reversed = true
            } else {
                playerLayer.player?.playImmediately(atRate: 1)
                reversed = false
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
