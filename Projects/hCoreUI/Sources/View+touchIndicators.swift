import SwiftUI
import UIKit

extension View {
    /// Shows a fading circle wherever the user touches while the screen is being captured (screen sharing, AirPlay
    /// mirroring, screen recording), so whoever is watching can follow along. Apply once, at the root of the scene.
    public func showsTouchesWhileCaptured() -> some View {
        background(TouchIndicatorInstaller().allowsHitTesting(false))
    }
}

/// Hooks into the hosting `UIWindow` once the SwiftUI hierarchy is attached to it.
private struct TouchIndicatorInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> TouchIndicatorInstallerView {
        TouchIndicatorInstallerView()
    }

    func updateUIView(_ uiView: TouchIndicatorInstallerView, context: Context) {}
}

private final class TouchIndicatorInstallerView: UIView {
    private var controller: TouchIndicatorController?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window, let scene = window.windowScene else {
            controller?.invalidate()
            controller = nil
            return
        }
        guard controller?.hostWindow !== window else { return }
        controller?.invalidate()
        controller = TouchIndicatorController(hostWindow: window, scene: scene)
    }
}

/// Observes the touches of the host window, and while the scene is captured mirrors them in a pass-through overlay
/// window above everything else.
@MainActor
private final class TouchIndicatorController {
    private(set) weak var hostWindow: UIWindow?
    private let recognizer = TouchObservingGestureRecognizer()
    private var overlayWindow: TouchOverlayWindow?
    private var traitRegistration: UITraitChangeRegistration?
    private weak var scene: UIWindowScene?

    init(hostWindow: UIWindow, scene: UIWindowScene) {
        self.hostWindow = hostWindow
        self.scene = scene
        recognizer.onTouches = { [weak self] touches in
            self?.handle(touches)
        }
        hostWindow.addGestureRecognizer(recognizer)
        traitRegistration = scene.registerForTraitChanges([UITraitSceneCaptureState.self]) {
            [weak self] (scene: UIWindowScene, _: UITraitCollection) in
            self?.updateOverlay(for: scene)
        }
        updateOverlay(for: scene)
    }

    func invalidate() {
        hostWindow?.removeGestureRecognizer(recognizer)
        if let traitRegistration {
            scene?.unregisterForTraitChanges(traitRegistration)
        }
        traitRegistration = nil
        removeOverlay()
    }

    private func updateOverlay(for scene: UIWindowScene) {
        if scene.traitCollection.sceneCaptureState == .active {
            guard overlayWindow == nil else { return }
            let window = TouchOverlayWindow(windowScene: scene)
            window.isHidden = false
            overlayWindow = window
        } else {
            removeOverlay()
        }
    }

    private func removeOverlay() {
        overlayWindow?.isHidden = true
        overlayWindow?.windowScene = nil
        overlayWindow = nil
    }

    private func handle(_ touches: Set<UITouch>) {
        guard let overlayWindow, let hostWindow else { return }
        for touch in touches {
            let point = hostWindow.convert(touch.location(in: hostWindow), to: overlayWindow)
            overlayWindow.update(touch: touch, at: point)
        }
    }
}

/// Never recognizes and never blocks or delays anything: it only reports the touches it sees.
private final class TouchObservingGestureRecognizer: UIGestureRecognizer {
    var onTouches: ((Set<UITouch>) -> Void)?

    init() {
        super.init(target: nil, action: nil)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        requiresExclusiveTouchType = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        onTouches?(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        onTouches?(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        onTouches?(touches)
        failIfAllTouchesEnded(event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        onTouches?(touches)
        failIfAllTouchesEnded(event)
    }

    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool { false }
    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool { false }

    private func failIfAllTouchesEnded(_ event: UIEvent) {
        let hasActiveTouches = event.allTouches?.contains { ![.ended, .cancelled].contains($0.phase) } ?? false
        if !hasActiveTouches {
            state = .failed
        }
    }
}

/// Topmost window that ignores all touches and only draws the touch indicators.
private final class TouchOverlayWindow: UIWindow {
    private var indicators: [ObjectIdentifier: UIView] = [:]
    private let indicatorSize: CGFloat = 44

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        windowLevel = .statusBar + 1
        backgroundColor = .clear
        isUserInteractionEnabled = false
        accessibilityElementsHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }

    func update(touch: UITouch, at point: CGPoint) {
        let id = ObjectIdentifier(touch)
        switch touch.phase {
        case .began:
            let indicator = makeIndicator()
            indicator.center = point
            addSubview(indicator)
            indicators[id] = indicator
            indicator.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            UIView.animate(withDuration: 0.15) {
                indicator.transform = .identity
            }
        case .moved, .stationary:
            indicators[id]?.center = point
        case .ended, .cancelled:
            guard let indicator = indicators.removeValue(forKey: id) else { return }
            indicator.center = point
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    indicator.alpha = 0
                    indicator.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                },
                completion: { _ in
                    indicator.removeFromSuperview()
                }
            )
        default:
            break
        }
    }

    private func makeIndicator() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: indicatorSize, height: indicatorSize))
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
        view.layer.cornerRadius = indicatorSize / 2
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        return view
    }
}
