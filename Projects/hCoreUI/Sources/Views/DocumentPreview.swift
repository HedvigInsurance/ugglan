import Combine
import SwiftUI
import WebKit
import hCore

public class DocumentPreviewModel: NSObject, ObservableObject {
    let type: DocumentPreviewType
    let id: String
    let webView = WKWebView()
    weak var vc: UIViewController?
    @Published var isLoading = true
    @Published var error: String?
    @Published var contentHeight: CGFloat = 0
    @Published var offset: CGFloat = 0
    @Published var showBlurred = false
    @Published var showFile = false
    var contentSizeCancellable: AnyCancellable?
    public init(id: String = "", type: DocumentPreviewType) {
        self.id = id
        self.type = type
        super.init()
        webView.navigationDelegate = self
        loadURL()
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            withAnimation(.easeInOut(duration: 1)) {
                self?.showBlurred = true
            }
        }
    }

    func loadURL() {
        withAnimation {
            isLoading = true
            error = nil
        }
        switch type {
        case .url(let url):
            let request = URLRequest(url: url, timeoutInterval: 5)
            webView.load(request)
        case .data(let data, let mimeType):
            webView.load(
                data,
                mimeType: mimeType.mime,
                characterEncodingName: "UTF-8",
                baseURL: URL(fileURLWithPath: "")
            )
        }
    }

    public enum DocumentPreviewType {
        case url(url: URL)
        case data(data: Data, mimeType: MimeType)
    }
}

public struct DocumentPreview: View {
    @ObservedObject var vm: DocumentPreviewModel
    @Namespace var animationNamespace

    public init(vm: DocumentPreviewModel) {
        self.vm = vm
    }

    public var body: some View {
        ZStack {
            HeroAnimationWrapper(id: "imagePreviewId_\(vm.id)") {
                DocumentPreviewWebView(documentPreviewModel: vm)
            }
            .frame(maxHeight: vm.contentHeight)
            .offset(x: vm.offset)
            .rotationEffect(.degrees(180 * Double(vm.offset) / 10000))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        vm.offset = gesture.translation.width
                    }
                    .onEnded { _ in
                        if abs(vm.offset) > 200 {
                            vm.vc?.dismiss(animated: true)
                        } else {
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                                vm.offset = .zero
                            }
                        }
                    }
            )
            .opacity(1 - Double(abs(vm.offset) / 1000))
            .opacity(vm.showFile ? 1 : 0)
            .frame(width: vm.contentHeight == 0 ? 0 : nil)
            if vm.isLoading || !vm.showFile {
                DotsActivityIndicator(.standard)
                    .useDarkColor
                    .padding(20)
                    .transition(.opacity)

            }
            if vm.error != nil {
                errorView
            }
            closeButton
        }
        .introspectViewController { vc in
            vm.vc = vc
        }
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            VStack {
                Button(
                    action: {
                        vm.vc?.dismiss(animated: true)
                    },
                    label: {
                        hCoreUIAssets.close.view
                            .foregroundColor(hTextColor.Opaque.primary)
                            .padding(8)
                            .background {
                                hBackgroundColor.primary.opacity(0.1)
                            }
                            .background {
                                BackgroundBlurView()
                            }
                            .clipShape(Circle())
                    }
                )
                .padding(8)
                Spacer()
            }
        }
    }

    private var errorView: some View {
        GenericErrorView(
            title: L10n.somethingWentWrong,
            description: L10n.General.errorBody,
            buttons: .init(
                actionButton:
                    .init(
                        buttonTitle: L10n.generalRetry,
                        buttonAction: {
                            vm.loadURL()
                        }
                    )
            )
        )
    }
}

extension DocumentPreviewModel: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.contentSizeCancellable = nil
            withAnimation {
                self?.isLoading = false
            }
            self?.webView.scrollView.setZoomScale(0.1, animated: true)
            withAnimation(.default.delay(0.2)) {
                self?.showFile = true
            }

        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        withAnimation {
            self.error = ""
            isLoading = false
        }
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: any Error
    ) {
        withAnimation {
            self.error = ""
            isLoading = false
        }
    }
}

struct DocumentPreviewWebView: UIViewRepresentable {
    let vm: DocumentPreviewModel
    init(documentPreviewModel: DocumentPreviewModel) {
        self.vm = documentPreviewModel
    }

    func makeUIView(context: Context) -> WKWebView {
        vm.webView.scrollView.backgroundColor = .clear
        vm.contentSizeCancellable = vm.webView.scrollView.publisher(for: \.contentSize)
            .sink(receiveValue: { [weak vm] value in
                vm?.contentHeight = value.height
            })
        vm.webView.scrollView.minimumZoomScale = 1
        vm.webView.backgroundColor = .clear
        vm.webView.scrollView.backgroundColor = .clear
        vm.webView.isOpaque = false
        return vm.webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

extension File {
    public var asDocumentPreviewType: DocumentPreviewModel.DocumentPreviewType? {
        switch source {
        case let .localFile(url, _):
            if let data = FileManager.default.contents(atPath: url.path) {
                return .data(data: data, mimeType: mimeType)
            }
            return nil
        case let .url(url):
            return .url(url: url)
        }
    }
}
