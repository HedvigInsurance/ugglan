import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit
import hCore

public struct Document {
    fileprivate static let certificateName = "Travel Insurance Certificate"
    fileprivate static let fileExt = ".pdf"
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
        viewController.title = title

        let pdfViewer = PDFViewer(downloadButtonTitle: downloadButtonTitle)
        bag += viewController.install(pdfViewer)

        pdfViewer.url.value = url

        let activityButton = UIBarButtonItem(system: .action)

        func transformDataToPresentation(data: Data) -> Presentation<ActivityView> {
            var thingToShare: Any = data
            if downloadButtonTitle != nil {
                let temporaryFolder = FileManager.default.temporaryDirectory
                let fileName = "\(Document.certificateName) \(Date().localDateString)\(Document.fileExt)"
                let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
                do {
                    try? FileManager.default.removeItem(at: temporaryFileURL)
                    try data.write(to: temporaryFileURL)
                    thingToShare = temporaryFileURL
                } catch let error {
                    print("\(#function): *** Error while writing to temporary file. \(error.localizedDescription)")
                }
            }

            let activityView = ActivityView(
                activityItems: [thingToShare],
                applicationActivities: nil,
                sourceView: activityButton.view,
                sourceRect: activityButton.bounds
            )

            let activityViewPresentation = Presentation(
                activityView,
                style: .activityView,
                options: .defaults
            )
            return activityViewPresentation
        }

        bag += pdfViewer.downloadButtonPressed
            .withLatestFrom(pdfViewer.data)
            .onValueDisposePrevious({ _, value -> Disposable? in
                guard let value = value else { return NilDisposer() }
                let activityViewPresentation = transformDataToPresentation(data: value)
                return viewController.present(activityViewPresentation).disposable
            })

        bag += viewController.navigationItem.addItem(activityButton, position: .right)
            .withLatestFrom(pdfViewer.data)
            .onValueDisposePrevious { _, value -> Disposable? in
                guard let value = value else { return NilDisposer() }
                let activityViewPresentation = transformDataToPresentation(data: value)
                return viewController.present(activityViewPresentation).disposable
            }

        return (viewController, bag)
    }
}
