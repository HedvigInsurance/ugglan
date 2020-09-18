import Flow
import Foundation
import hCoreUI
import Presentation
import UIKit
import WebKit

struct KeyGearReceipt {
    let receipt: URL
}

extension KeyGearReceipt: Presentable {
    class KeyGearReceiptViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = KeyGearReceiptViewController()

        let activityButton = UIBarButtonItem(system: .action)

        bag += viewController.navigationItem.addItem(
            activityButton,
            position: .right
        ).compactMap(on: .background) { try? Data(contentsOf: self.receipt) }.onValueDisposePrevious { data -> Disposable? in

            let activityView = ActivityView(
                activityItems: [data],
                applicationActivities: nil,
                sourceView: activityButton.view,
                sourceRect: activityButton.bounds
            )

            let activityViewPresentation = Presentation(
                activityView,
                style: .activityView,
                options: .defaults
            )

            return viewController.present(activityViewPresentation).disposable
        }

        if receipt.pathExtension == "pdf" {
            let pdfViewer = PDFViewer()
            bag += viewController.install(pdfViewer)

            pdfViewer.url.value = receipt
        } else {
            let webView = WKWebView()
            webView.backgroundColor = .brand(.primaryBackground())
            webView.load(URLRequest(url: receipt))

            viewController.view = webView
        }

        return (viewController, bag)
    }
}
