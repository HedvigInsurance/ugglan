import SwiftUI
import UIKit

final class SwipeBackToggleHostingController: UIViewController {
    private let child: UIViewController

    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        child.didMove(toParent: self)
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
        host?.setSwipeBackEnabled(isEnabled)
    }
}
