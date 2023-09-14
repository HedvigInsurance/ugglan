import AVKit
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct NotLoggedInView: View {
    var onLoad: () -> Void
    @ObservedObject var viewModel = NotLoggedViewModel()
    @PresentableStore var store: MarketStore

    @State var title: String = L10n.MarketLanguageScreen.title
    @State var buttonText: String = L10n.MarketLanguageScreen.continueButtonText

    enum ViewState {
        case loading
        case marketAndLanguage
    }
    @State var viewState: ViewState = .loading

    public init(
        onLoad: @escaping () -> Void
    ) {
        self.onLoad = onLoad
        ApplicationState.preserveState(.notLoggedIn)

        viewModel.fetchMarketingImage()
        viewModel.detectMarketFromLocation()
    }

    @ViewBuilder
    var marketAndLanguage: some View {
        ZStack {
            Image(uiImage: hCoreUIAssets.wordmark.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .offset(y: -24)
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

                        } label: {
                            Image(uiImage: market.icon)
                                .padding(8)
                        }

                    }

                }
                Spacer()
                VStack {
                    hButton.LargeButtonPrimary {
                        store.send(.loginButtonTapped)
                    } content: {
                        hText(L10n.bankidLoginTitle)
                    }

                    hButton.LargeButtonGhost {
                        store.send(.onboard)
                    } content: {
                        hText(L10n.marketingGetHedvig)
                    }

                }
            }
        }
    }

    public var body: some View {
        VStack {
            switch viewState {
            case .loading:
                ZStack {}
            case .marketAndLanguage:
                marketAndLanguage
            }
        }
        .environment(\.colorScheme, .light)
        .padding(.horizontal, 16)
        .opacity(viewState == .loading ? 0 : 1)
        .onReceive(
            Localization.Locale.$currentLocale
                .distinct()
                .plain()
                .delay(by: 0.1)
                .publisher
        ) { _ in
            self.title = L10n.MarketLanguageScreen.title
            self.buttonText = L10n.MarketLanguageScreen.continueButtonText
        }
        .onReceive(viewModel.$bootStrapped) { val in
            if val {
                hAnalyticsEvent.screenView(screen: .marketPicker).send()
                self.viewState = .marketAndLanguage
                onLoad()
            }
        }
        .background(
            PlayerView().ignoresSafeArea().animation(nil)
        )

    }

}

struct NotLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoggedInView {

        }
    }
}
struct PlayerView: UIViewRepresentable {

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
}

class PlayerUIView: UIView {
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
        let fileUrl = Bundle.module.url(forResource: "9x16_pillow", withExtension: "mp4")!

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
