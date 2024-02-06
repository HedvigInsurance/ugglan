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
    public init(
        url: URL,
        title: String
    ) {
        self.url = url
        self.title = title
    }

}

extension Document: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.edgesForExtendedLayout = []
        viewController.title = title

        let pdfViewer = PDFViewer()
        bag += viewController.install(pdfViewer)

        pdfViewer.url.value = url

        let activityButton = UIBarButtonItem(system: .action)

        func getPathForFile() -> URL {
            let temporaryFolder = FileManager.default.temporaryDirectory
            let fileName = "\(title) \(Date().localDateString).pdf"
            let url = temporaryFolder.appendingPathComponent(fileName)
            return url
        }
        func transformDataToPresentation(data: Data) -> Presentation<ActivityView> {
            var thingToShare: Any = data
            let temporaryFileURL = getPathForFile()
            do {
                try? FileManager.default.removeItem(at: temporaryFileURL)
                try data.write(to: temporaryFileURL)
                thingToShare = temporaryFileURL
            } catch let error {
                print("\(#function): *** Error while writing to temporary file. \(error.localizedDescription)")
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

        bag += viewController.navigationItem.addItem(activityButton, position: .right)
            .withLatestFrom(pdfViewer.data)
            .onValueDisposePrevious { _, value -> Disposable? in
                guard let value = value else { return NilDisposer() }
                let activityViewPresentation = transformDataToPresentation(data: value)
                    .onDismiss {
                        try? FileManager.default.removeItem(at: getPathForFile())
                    }
                return viewController.present(activityViewPresentation).disposable
            }
        return (viewController, bag)
    }
}
