import AVKit
import Apollo
import Authentication
import Combine
import Foundation
import Market
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct LoginNavigation: View {
    @ObservedObject var vm: NotLoggedViewModel
    @StateObject private var router = Router()
    @StateObject private var otpState = OTPState()
    var body: some View {
        RouterHost(router: router, options: .navigationBarHidden) {
            NotLoggedInView(vm: vm)
        }
        .detent(presented: $vm.showLanguagePicker, style: .height) {
            LanguageAndMarketPickerView()
                .navigationTitle(L10n.loginMarketPickerPreferences)
                .embededInNavigation()

        }
        .detent(presented: $vm.showLogin, style: .large, tracking: Localization.Locale.currentLocale.market) {
            Group {
                switch Localization.Locale.currentLocale.market {
                case .no, .dk:
                    OTPEntryView()
                case .se:
                    BankIDLoginQRView {
                        let store: UgglanStore = globalPresentableStoreContainer.get()
                        await store.sendAsync(.setIsDemoMode(to: true))
                        ApolloClient.initAndRegisterClient()
                    }
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
            .embededInNavigation()
        }
    }
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
                    case .marketAndLanguage:
                        marketAndLanguage
                    }
                }
                .environment(\.colorScheme, .light)
                .opacity(vm.viewState == .loading ? 0 : 1)
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    var marketAndLanguage: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    PresentableStoreLens(
                        MarketStore.self,
                        getter: { state in
                            state.market
                        }
                    ) { market in
                        Button {
                            vm.showLanguagePicker = true
                        } label: {
                            Image(uiImage: market.icon)
                                .padding(.padding8)
                        }

                    }

                }
                Spacer()
                VStack {
                    hButton.LargeButton(type: .primary) {
                        vm.showLogin = true
                    } content: {
                        hText(L10n.bankidLoginTitle)
                    }

                    hButton.LargeButton(type: .ghost) {
                        vm.onOnBoardPressed()
                    } content: {
                        hText(L10n.marketingGetHedvig)
                    }

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

public class NotLoggedViewModel: ObservableObject {
    @PresentableStore var store: MarketStore
    @Published var blurHash: String = ""
    @Published var imageURL: String = ""
    @Published var bootStrapped: Bool = false
    @Published var locale: Localization.Locale = .currentLocale
    @Published var title: String = L10n.MarketLanguageScreen.title
    @Published var buttonText: String = L10n.MarketLanguageScreen.continueButtonText
    @Published var viewState: ViewState = .loading
    @Published var showLanguagePicker = false
    @Published var showLogin = false
    let router = Router()
    var onLoad: () -> Void = {}
    var cancellables = Set<AnyCancellable>()

    init() {
        Localization.Locale.$currentLocale
            .distinct()
            .plain()
            .delay(by: 0.1)
            .publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.title = L10n.MarketLanguageScreen.title
                self?.buttonText = L10n.MarketLanguageScreen.continueButtonText
            }
            .store(in: &cancellables)

        $bootStrapped
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    self?.viewState = .marketAndLanguage
                    self?.onLoad()
                }
            }
            .store(in: &cancellables)

        self.bootStrapped = true

        NotificationCenter.default.addObserver(forName: .openDeepLink, object: nil, queue: nil) {
            [weak self] notification in
            if let url = notification.object as? URL {
                if url.relativePath.contains("login-failure") {
                    self?.router.push(AuthentificationRouterType.error(message: L10n.authenticationBankidLoginError))
                }
            }
        }

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func onOnBoardPressed() {
        var webUrl = Environment.current.webBaseURL
        webUrl.appendPathComponent(Localization.Locale.currentLocale.webPath)
        webUrl.appendPathComponent(Localization.Locale.currentLocale.priceQoutePath)
        webUrl =
            webUrl
            .appending("utm_source", value: "ios")
            .appending("utm_medium", value: "hedvig-app")
            .appending("utm_campaign", value: Localization.Locale.currentLocale.market.rawValue.lowercased())
        UIApplication.shared.open(webUrl)

    }

    enum ViewState {
        case loading
        case marketAndLanguage
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

extension Localization.Locale.Market: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .no, .dk:
            return .init(describing: OTPEntryView.self)
        case .se:
            return .init(describing: BankIDLoginQRView.self)

        }
    }
}
