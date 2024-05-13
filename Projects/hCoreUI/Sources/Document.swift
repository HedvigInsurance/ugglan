import Flow
import Foundation
import PDFKit
import SafariServices
import SwiftUI
import hCore

public struct Document: Equatable, Identifiable {
    public var id: String?
    public let url: URL
    public let title: String

    public init(
        url: URL,
        title: String
    ) {
        self.url = url
        self.title = title
    }

}

public struct PDFPreview: View {
    @StateObject fileprivate var vm: PDFPreviewViewModel

    public init(
        document: Document
    ) {
        _vm = StateObject(wrappedValue: PDFPreviewViewModel(document: document))
    }

    public var body: some View {
        Group {
            if vm.isLoading {
                loadingIndicatorView
            } else if let data = vm.data {
                DocumentRepresentable(data: data, name: vm.document.title)
                    .introspectViewController { vc in
                        let navBarItem = UIBarButtonItem(
                            image: UIImage(systemName: "square.and.arrow.up"),
                            style: .plain,
                            target: vm,
                            action: #selector(vm.transformDataToActivityView)
                        )
                        vm.navItem = navBarItem
                        vc.navigationItem.leftBarButtonItem = navBarItem
                    }
            } else {
                GenericErrorView(buttons: .init())
            }
        }
        .navigationTitle(vm.document.title)
        .navigationBarTitleDisplayMode(.inline)
        .embededInNavigation()
        .withDismissButton()
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

private class PDFPreviewViewModel: ObservableObject {
    let document: Document
    @Published var isLoading = false
    @Published var data: Data?
    weak var navItem: UIBarButtonItem?
    init(document: Document) {
        self.document = document
        Task {
            await self.getData()
        }
    }

    @MainActor
    private func getData() async {
        withAnimation {
            self.isLoading = true
        }
        do {
            let data = try download()
            withAnimation {
                self.data = data
            }
        } catch _ {}
        withAnimation {
            self.isLoading = false
        }
    }

    private func download() throws -> Data {
        do {
            let data = try Data(contentsOf: self.document.url)
            return data
        } catch let ex {
            throw ex
        }
    }

    @objc func transformDataToActivityView() {
        let data = self.data!
        var thingToShare: Any = data
        let temporaryFileURL = getPathForFile()
        do {
            try? FileManager.default.removeItem(at: temporaryFileURL)
            try data.write(to: temporaryFileURL)
            thingToShare = temporaryFileURL
        } catch let error {
            print("\(#function): *** Error while writing to temporary file. \(error.localizedDescription)")
        }

        let viewController = UIActivityViewController(
            activityItems: [thingToShare],
            applicationActivities: nil
        )
        viewController.preferredPresentationStyle = .activityView

        if let popover = viewController.popoverPresentationController, let sourceRect = navItem?.bounds {
            popover.sourceView = navItem!.view
            popover.sourceRect = sourceRect
        }

        UIApplication.shared.getTopViewController()?.present(viewController, animated: true)
    }

    private func getPathForFile() -> URL {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "\(document.title).pdf"
        let url = temporaryFolder.appendingPathComponent(fileName)
        return url
    }
}

private struct DocumentRepresentable: UIViewRepresentable {
    let data: Data
    let name: String

    func makeUIView(context: Context) -> some UIView {
        return DocumentView(data: data, name: name)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

private class DocumentView: UIView {
    let data: Data
    let name: String
    private let pdfView = PDFView()

    init(
        data: Data,
        name: String
    ) {
        self.data = data
        self.name = name
        super.init(frame: .zero)

        pdfView.backgroundColor = .brand(.primaryBackground())
        pdfView.maxScaleFactor = 3
        pdfView.autoScales = true
        self.addSubview(pdfView)
        pdfView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pdfView.document = PDFDocument(data: data)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
