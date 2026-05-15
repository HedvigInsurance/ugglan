@preconcurrency import HedvigShared
import SwiftUI
import UIKit

@MainActor
final class SwipeBackToggleHostingController: UIViewController {
    private let child: UIViewController
    // Compose doesn't expose its real scroll position through any native UIScrollView,
    // so we use a hidden dummy one as the nav bar's tracked content scroll view and
    // forward Compose's scroll offset onto its contentOffset. iOS then drives the
    // scroll-edge appearance transition the standard way.
    private let trackingScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(trackingScrollView)
        NSLayoutConstraint.activate([
            trackingScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            trackingScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackingScrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            trackingScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 1),
        ])
        setContentScrollView(trackingScrollView)
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        trackingScrollView.addSubview(child.view)
        child.view.insetsLayoutMarginsFromSafeArea = true
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: trackingScrollView.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: trackingScrollView.bottomAnchor),
            child.view.widthAnchor.constraint(equalTo: trackingScrollView.widthAnchor),
            child.view.heightAnchor.constraint(equalTo: trackingScrollView.heightAnchor),
        ])
        child.didMove(toParent: self)
    }

    func setScrollOffset(_ offset: CGFloat) {
        let y = min(1, max(0, offset))
        guard y != trackingScrollView.contentOffset.y else { return }
        trackingScrollView.contentOffset = CGPoint(x: 0, y: y)
    }

    // NavigationStack on iOS 18+/26 uses a private pan recognizer for swipe-back
    // in addition to interactivePopGestureRecognizer, so toggle every
    // UIPanGestureRecognizer up the nav controller's view chain.
    func setSwipeBackEnabled(_ enabled: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = enabled
        var view: UIView? = navigationController?.view
        while let current = view {
            for gr in current.gestureRecognizers ?? [] where gr is UIPanGestureRecognizer {
                gr.isEnabled = enabled
            }
            view = current.superview
        }
    }
}

final class SwipeBackBridge: NSObject, IosSwipeBackController {
    weak var host: SwipeBackToggleHostingController?

    func setSwipeBackEnabled(isEnabled: Bool) {
        Task { [host] in
            await host?.setSwipeBackEnabled(isEnabled)
        }
    }

    func setScrollOffset(_ offset: CGFloat) {
        Task { [host] in
            await host?.setScrollOffset(offset)
        }
    }
}
