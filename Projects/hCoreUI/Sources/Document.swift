import Foundation
import hCore
import PDFKit
import SafariServices
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct PDFPreview: View {
    @StateObject fileprivate var vm: PDFPreviewViewModel

    public init(
        document: hPDFDocument
    ) {
        _vm = StateObject(wrappedValue: PDFPreviewViewModel(document: document))
    }

    public var body: some View {
        Group {
            if vm.isLoading {
                loadingIndicatorView
            } else if let data = vm.data {
                DocumentRepresentable(data: data, name: vm.document.displayName)
                    .introspect(.viewController, on: .iOS(.v13...)) { vc in
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
                GenericErrorView(
                    formPosition: .center
                )
                .hStateViewButtonConfig(.init())
            }
        }
        .navigationTitle(vm.document.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .embededInNavigation(tracking: self)
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

@MainActor
private class PDFPreviewViewModel: ObservableObject {
    let document: hPDFDocument
    @Published var isLoading = false
    @Published var data: Data?
    weak var navItem: UIBarButtonItem?
    init(document: hPDFDocument) {
        self.document = document
        Task {
            await self.getData()
        }
    }

    @MainActor
    private func getData() async {
        isLoading = true
        do {
            let data = try await download()
            withAnimation {
                self.data = data
            }
        } catch _ {}
        withAnimation {
            self.isLoading = false
        }
    }

    private func download() async throws -> Data? {
        do {
            if let url = URL(string: document.url) {
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            }
            return nil
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
        } catch {
            print("\(#function): *** Error while writing to temporary file. \(error.localizedDescription)")
        }
        Task { @MainActor in
            let viewController = UIActivityViewController(
                activityItems: [thingToShare],
                applicationActivities: nil
            )

            if let popover = viewController.popoverPresentationController, let sourceRect = navItem?.bounds {
                popover.sourceView = navItem!.view
                popover.sourceRect = sourceRect
            }

            UIApplication.shared.getTopViewController()?.present(viewController, animated: true)
        }
    }

    private func getPathForFile() -> URL {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "\(document.displayName).pdf"
        let url = temporaryFolder.appendingPathComponent(fileName)
        return url
    }
}

private struct DocumentRepresentable: UIViewRepresentable {
    let data: Data
    let name: String

    func makeUIView(context _: Context) -> some UIView {
        DocumentView(data: data, name: name)
    }

    func updateUIView(_: UIViewType, context _: Context) {}
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
        addSubview(pdfView)
        pdfView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pdfView.document = PDFDocument(data: data)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PDFPreview: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: PDFPreview.self)
    }
}
