import SafariServices
import SwiftUI
import WebKit

public struct SafariView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = ReloadingSafariViewController

    @Binding var url: URL?

    public init(
        url: Binding<URL?>
    ) {
        _url = url
    }

    public func makeUIViewController(
        context _: UIViewControllerRepresentableContext<SafariView>
    ) -> ReloadingSafariViewController {
        ReloadingSafariViewController()
    }

    public func updateUIViewController(
        _ safariViewController: ReloadingSafariViewController,
        context _: UIViewControllerRepresentableContext<SafariView>
    ) {
        safariViewController.url = url
    }
}

public class ReloadingSafariViewController: UIViewController {
    public var url: URL? {
        didSet {
            configureChildViewController()
        }
    }

    private var safariViewController: SFSafariViewController?

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureChildViewController()
    }

    private func configureChildViewController() {
        if let safariViewController = safariViewController {
            safariViewController.willMove(toParent: self)
            safariViewController.view.removeFromSuperview()
            safariViewController.removeFromParent()
            self.safariViewController = nil
        }

        guard let url = url else { return }

        let newSafariViewController = SFSafariViewController(url: url)
        addChild(newSafariViewController)
        newSafariViewController.view.frame = view.frame
        view.addSubview(newSafariViewController.view)
        newSafariViewController.didMove(toParent: self)
        safariViewController = newSafariViewController
    }
}
