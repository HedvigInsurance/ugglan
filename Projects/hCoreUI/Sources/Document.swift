import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit
import hCore

public struct Document {
    let url: URL
    let title: String
    let downloadButtonTitle: String?
    public init(
        url: URL,
        title: String,
        downloadButtonTitle: String? = nil
    ) {
        self.url = url
        self.title = title
        self.downloadButtonTitle = downloadButtonTitle
    }
}


extension Document: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.edgesForExtendedLayout = []
        viewController.navigationItem.scrollEdgeAppearance = DefaultStyling.standardNavigationBarAppearance()
        viewController.title = title

        let pdfViewer = PDFViewer(downloadButtonTitle: downloadButtonTitle)
        bag += viewController.install(pdfViewer)
        
        pdfViewer.url.value = url

        let activityButton = UIBarButtonItem(system: .action)

        
        
        bag += pdfViewer.downloadButtonPressed
            .withLatestFrom(pdfViewer.data)
            .onValueDisposePrevious({ _, value -> Disposable? in
                guard let value = value else { return NilDisposer() }

                let activityView = ActivityView(
                    activityItems: [value],
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
            })

        bag += viewController.navigationItem.addItem(activityButton, position: .right)
            .withLatestFrom(pdfViewer.data)
            .onValueDisposePrevious { _, value -> Disposable? in
                guard let value = value else { return NilDisposer() }

                let activityView = ActivityView(
                    activityItems: [value],
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

        return (viewController, bag)
    }
}
