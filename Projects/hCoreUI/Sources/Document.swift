import Flow
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

        bag += viewController.navigationItem.addItem(activityButton, position: .right)
            .withLatestFrom(pdfViewer.data)
            .onValue {
                [weak activityButton, weak viewController] _, value
                in guard let activityButton = activityButton, let viewController = viewController else { return }
                guard let value = value else { return }
                let activityViewPresentation = transformDataToPresentationn(source: activityButton, data: value)
                viewController.present(activityViewPresentation)
            }
        bag += viewController.deallocSignal.onValue({ _ in
            try? FileManager.default.removeItem(at: getPathForFile())
        })
        return (viewController, bag)
    }

    private func transformDataToPresentationn(source: UIBarButtonItem, data: Data) -> ActivityView {
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
            sourceView: source.view,
            sourceRect: source.bounds
        )

        let activityViewPresentation = Presentation(
            activityView,
            style: .activityView,
            options: .defaults
        )
        return activityView
    }

    private func getPathForFile() -> URL {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "\(title).pdf"
        let url = temporaryFolder.appendingPathComponent(fileName)
        return url
    }
}
