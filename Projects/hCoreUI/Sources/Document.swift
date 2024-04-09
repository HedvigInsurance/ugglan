import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
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

private class DocumentView: UIView {
    var document: Document

    init(
        document: Document
    ) {
        self.document = document
        super.init(frame: .zero)

        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.edgesForExtendedLayout = []
        viewController.title = document.title

        let pdfViewer = PDFViewer()
        bag += viewController.install(pdfViewer)

        pdfViewer.url.value = document.url

        let activityButton = UIBarButtonItem(system: .action)

        bag += viewController.navigationItem.addItem(activityButton, position: .right)
            .withLatestFrom(pdfViewer.data)
            .onValue {
                [weak activityButton, weak viewController] _, value
                in guard let activityButton = activityButton, let viewController = viewController else { return }
                guard let value = value else { return }
                let activityViewPresentation = self.transformDataToActivityView(source: activityButton, data: value)
                viewController.present(activityViewPresentation)
            }
        bag += viewController.deallocSignal.onValue({ _ in
            try? FileManager.default.removeItem(at: self.getPathForFile())
        })
        //        return (viewController, bag)
        self.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
    }

    private func transformDataToActivityView(source: UIBarButtonItem, data: Data) -> ActivityView {
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
        return activityView
    }

    private func getPathForFile() -> URL {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "\(document.title).pdf"
        let url = temporaryFolder.appendingPathComponent(fileName)
        return url
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct DocumentRepresentable: UIViewRepresentable {
    private var document: Document

    public init(document: Document) {
        self.document = document
    }

    public func makeUIView(context: Context) -> some UIView {
        return DocumentView(document: document)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

//extension Document: Presentable {
//    public func materialize() -> (UIViewController, Disposable) {
//        let bag = DisposeBag()
//
//        let viewController = UIViewController()
//        viewController.edgesForExtendedLayout = []
//        viewController.title = title
//
//        let pdfViewer = PDFViewer()
//        bag += viewController.install(pdfViewer)
//
//        pdfViewer.url.value = url
//
//        let activityButton = UIBarButtonItem(system: .action)
//
//        bag += viewController.navigationItem.addItem(activityButton, position: .right)
//            .withLatestFrom(pdfViewer.data)
//            .onValue {
//                [weak activityButton, weak viewController] _, value
//                in guard let activityButton = activityButton, let viewController = viewController else { return }
//                guard let value = value else { return }
//                let activityViewPresentation = transformDataToActivityView(source: activityButton, data: value)
//                viewController.present(activityViewPresentation)
//            }
//        bag += viewController.deallocSignal.onValue({ _ in
//            try? FileManager.default.removeItem(at: getPathForFile())
//        })
//        return (viewController, bag)
//    }

//    private func transformDataToActivityView(source: UIBarButtonItem, data: Data) -> ActivityView {
//        var thingToShare: Any = data
//        let temporaryFileURL = getPathForFile()
//        do {
//            try? FileManager.default.removeItem(at: temporaryFileURL)
//            try data.write(to: temporaryFileURL)
//            thingToShare = temporaryFileURL
//        } catch let error {
//            print("\(#function): *** Error while writing to temporary file. \(error.localizedDescription)")
//        }
//
//        let activityView = ActivityView(
//            activityItems: [thingToShare],
//            applicationActivities: nil,
//            sourceView: source.view,
//            sourceRect: source.bounds
//        )
//        return activityView
//    }

//    private func getPathForFile() -> URL {
//        let temporaryFolder = FileManager.default.temporaryDirectory
//        let fileName = "\(title).pdf"
//        let url = temporaryFolder.appendingPathComponent(fileName)
//        return url
//    }
//}
