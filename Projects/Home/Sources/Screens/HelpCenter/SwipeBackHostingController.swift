import UIKit

final class SwipeBackHostingController: UIViewController, UIGestureRecognizerDelegate {
    private let child: UIViewController
    private weak var previousDelegate: UIGestureRecognizerDelegate?

    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let recognizer = navigationController?.interactivePopGestureRecognizer else { return }
        previousDelegate = recognizer.delegate
        recognizer.delegate = self
        recognizer.isEnabled = true
        recognizer.addTarget(self, action: #selector(handleInteractivePop(_:)))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let recognizer = navigationController?.interactivePopGestureRecognizer else { return }
        if recognizer.delegate === self {
            recognizer.delegate = previousDelegate
        }
        recognizer.removeTarget(self, action: #selector(handleInteractivePop(_:)))
        // Always restore — if we leave the screen mid-gesture we mustn't leak a disabled child.
        child.view.isUserInteractionEnabled = true
    }

    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }

    /// When the system's edge-pan fires, Compose may already be tracking the same touch
    /// (e.g. as a horizontal scroll on a list row). Toggling `isUserInteractionEnabled`
    /// makes UIKit deliver `touchesCancelled` so Compose abandons the in-flight gesture.
    /// Restored on gesture end so taps work again immediately.
    @objc private func handleInteractivePop(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            child.view.isUserInteractionEnabled = false
        case .ended, .cancelled, .failed:
            child.view.isUserInteractionEnabled = true
        default:
            break
        }
    }
}
