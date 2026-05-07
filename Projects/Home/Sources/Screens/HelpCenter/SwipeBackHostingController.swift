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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let recognizer = navigationController?.interactivePopGestureRecognizer,
              recognizer.delegate === self else { return }
        recognizer.delegate = previousDelegate
    }

    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}
