import AVKit
import SwiftUI

struct LoginVideoView: UIViewRepresentable {

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LoginVideoView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
}

private class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Load video resource
        guard let fileUrl = Bundle.main.url(forResource: "9x16_pillow", withExtension: "mp4") else {
            print("❌ Video file not found")
            return
        }

        let asset = AVAsset(url: fileUrl)
        let playerItem = AVPlayerItem(asset: asset)

        // Setup player and looper
        let player = AVQueuePlayer()
        let looper = AVPlayerLooper(player: player, templateItem: playerItem)

        self.queuePlayer = player
        self.looper = looper

        player.isMuted = true
        player.play()

        // Setup layer
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(playerLayer)

        // Resume playback on foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        // Setup audio session (optional, if video has sound and should play silently)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Failed to configure audio session: \(error)")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        playerLayer.contentsScale = UIScreen.main.scale
    }

    @objc
    func didEnterForeground() {
        queuePlayer?.play()
    }
}
