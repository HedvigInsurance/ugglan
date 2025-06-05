import AVKit
import Apollo
import Authentication
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
        .detent(presented: $vm.showLanguagePicker, transitionType: .detent(style: [.height])) {
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
        .detent(presented: $vm.showLogin, transitionType: .detent(style: [.large])) {
            Group {
                BankIDLoginQRView {
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    await store.sendAsync(.setIsDemoMode(to: true))
                    ApolloClient.initAndRegisterClient()
                }
            }
            .environmentObject(otpState)
            .withDismissButton()
            .routerDestination(for: AuthenticationRouterType.self) { type in
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
