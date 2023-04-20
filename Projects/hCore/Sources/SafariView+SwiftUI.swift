import Flow
import Form
import Presentation
import SafariServices
import SwiftUI
import UIKit
import WebKit

public struct SafariView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = ReloadingSafariViewController

    @Binding var url: URL?

    public init(
        url: Binding<URL?>
    ) {
        self._url = url
    }

    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<SafariView>
    ) -> ReloadingSafariViewController {
        return ReloadingSafariViewController()
    }

    public func updateUIViewController(
        _ safariViewController: ReloadingSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
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

    public override func viewDidLoad() {
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
        self.safariViewController = newSafariViewController
    }
}
