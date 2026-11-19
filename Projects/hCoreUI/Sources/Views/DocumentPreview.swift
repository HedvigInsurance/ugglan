import AVKit
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import WebKit
import hCore

@MainActor
@Observable
public class DocumentPreviewModel: NSObject {
    let type: DocumentPreviewType
    let webView = CenteredContentWebView(frame: .zero, configuration: WKWebViewConfiguration())
    let player: AVPlayer?
    @ObservationIgnored weak var vc: UIViewController? {
        didSet {
            guard type.name != nil else { return }
            setupShareButton()
        }
    }
    var isLoading = true
    var error: String?
    var offset: CGFloat = 0
    var opacity: Double = 0

    @ObservationIgnored private var temporaryFileURL: URL?

    public init(type: DocumentPreviewType) {
        self.type = type
        switch type {
        case let .url(url, _, mimeType):
            if mimeType.isVideo {
                player = AVPlayer(url: url)
                player?.play()
            } else {
                player = nil
            }
        case .data:
            player = nil
        }
        super.init()
        webView.navigationDelegate = self
        if type.mimeType.isImage {
            webView.centerImageDocument()
        }
        if player == nil {
            loadURL()
        }
    }

    deinit {
        if let url = temporaryFileURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func cleanupTemporaryFile() {
        guard let url = temporaryFileURL else { return }
        try? FileManager.default.removeItem(at: url)
        temporaryFileURL = nil
    }

    func loadURL() {
        withAnimation {
            isLoading = true
            error = nil
        }
        switch type {
        case let .url(url, _, _):
            let request = URLRequest(url: url, timeoutInterval: 5)
            webView.load(request)
        case let .data(data, _, mimeType):
            webView.load(
                data,
                mimeType: mimeType.mime,
                characterEncodingName: "UTF-8",
                baseURL: URL(fileURLWithPath: "")
            )
        }
    }

    public enum DocumentPreviewType: Equatable, Identifiable {
        public var id: String {
            switch self {
            case let .url(url, _, _):
                return url.absoluteString
            case let .data(data, _, _):
                return "\(data.count)"
            }
        }

        var name: String? {
            switch self {
            case .url(_, let name, _):
                return name
            case .data(_, let name, _):
                return name
            }
        }
        var mimeType: MimeType {
            switch self {
            case .url(_, _, let mimeType):
                return mimeType
            case .data(_, _, let mimeType):
                return mimeType
            }
        }

        case url(url: URL, name: String?, mimeType: MimeType)
        case data(data: Data, name: String?, mimeType: MimeType)
    }

    private func setupShareButton() {
        let color = hTextColor.Opaque.primary.uiColor()
        let image = UIImage(systemName: "square.and.arrow.up")?
            .withTintColor(color, renderingMode: .alwaysTemplate)
        let barButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(share(sender:))
        )
        vc?.navigationItem.leftBarButtonItem = barButtonItem
    }

    @objc func share(sender: UIBarButtonItem) {
        Task {
            do {
                let data = try await fetchData()
                guard let name = type.name else { return }
                let fileURL = try createTemporaryFile(data: data, name: name, ext: type.mimeType.name)
                presentShareSheet(for: fileURL, from: sender)
            } catch {
                Toasts.shared.displayToastBar(toast: .init(type: .error, text: L10n.somethingWentWrong))
            }
        }
    }

    private func fetchData() async throws -> Data {
        switch type {
        case let .url(url, _, _):
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        case let .data(data, _, _):
            return data
        }
    }

    private func createTemporaryFile(data: Data, name: String, ext: String) throws -> URL {
        cleanupTemporaryFile()

        let contentURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(name)
            .appendingPathExtension(ext)
        if FileManager.default.fileExists(atPath: contentURL.path) {
            try FileManager.default.removeItem(at: contentURL)
        }
        try data.write(to: contentURL)
        temporaryFileURL = contentURL
        return contentURL
    }

    private func presentShareSheet(for url: URL, from sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = sender.view
        vc?.present(activityViewController, animated: true)
    }
}

public struct DocumentPreview: View {
    let vm: DocumentPreviewModel
    public init(vm: DocumentPreviewModel) {
        self.vm = vm
    }

    public var body: some View {
        ZStack {
            BackgroundBlurView()
                .ignoresSafeArea()
            if let player = vm.player {
                VideoPlayer(player: player)
            } else {
                DocumentPreviewWebView(documentPreviewModel: vm)
                    .offset(x: vm.offset)
                    .rotationEffect(.degrees(180 * Double(vm.offset) / 10000))
                    .accessibilityAction(named: Text(L10n.generalCloseButton)) {
                        vm.vc?.dismiss(animated: true)
                    }
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
                    .opacity(vm.opacity)
                if vm.isLoading {
                    DotsActivityIndicator(.standard)
                        .useDarkColor
                }
                if vm.error != nil {
                    GenericErrorView(
                        title: L10n.somethingWentWrong,
                        description: L10n.General.errorBody,
                        formPosition: .center
                    )
                    .hStateViewButtonConfig(
                        .init(
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
        }
        .introspect(.viewController, on: .iOS(.v17...)) { [weak vm] vc in
            if vm?.vc != vc {
                vm?.vc = vc
            }
        }
        .navigationTitle(vm.type.name ?? "")
        .embededInNavigation(tracking: self)
    }
}

extension DocumentPreview: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: DocumentPreview.self)
    }
}

extension DocumentPreviewModel: WKNavigationDelegate {
    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        withAnimation {
            isLoading = false
        }
        withAnimation(.easeInOut(duration: 0.1)) {
            self.opacity = 1
        }
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: any Error) {
        withAnimation {
            self.error = ""
            isLoading = false
        }
    }

    public func webView(
        _: WKWebView,
        didFailProvisionalNavigation _: WKNavigation!,
        withError _: any Error
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
        vm = documentPreviewModel
    }

    func makeUIView(context _: Context) -> WKWebView {
        vm.webView.scrollView.backgroundColor = .clear
        vm.webView.scrollView.minimumZoomScale = 1
        vm.webView.backgroundColor = .clear
        vm.webView.isOpaque = false
        vm.webView.viewController?.view.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak vm] in
            vm?.webView.viewController?.view.backgroundColor = .brand(.primaryBackground()).withAlphaComponent(0.55)
        }
        return vm.webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}
}

/// Web view that vertically centers its content when the content is shorter than the visible area.
/// Insets handle scrollable content such as PDFs; image documents need ``centerImageDocument()``.
final class CenteredContentWebView: WKWebView {
    private var contentSizeObservation: NSKeyValueObservation?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        contentSizeObservation = scrollView.observe(\.contentSize) { [weak self] _, _ in
            MainActor.assumeIsolated {
                self?.centerContentVertically()
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerContentVertically()
    }

    /// WebKit renders an image document with a body exactly as tall as the viewport and the image pinned to the top,
    /// so there is no spare scroll content to center with insets. Center the image inside the page instead.
    /// `margin: auto` (not `align-items: center`) keeps images taller than the viewport scrollable from the top.
    func centerImageDocument() {
        let css = "html, body { margin: 0; min-height: 100vh; } body { display: flex; } img { margin: auto; }"
        let source = """
            const style = document.createElement('style');
            style.textContent = '\(css)';
            document.head.appendChild(style);
            """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }

    private func centerContentVertically() {
        // adjustedContentInset includes our own contentInset, so subtract it to get only the system (safe area) part
        let systemInsetTop = scrollView.adjustedContentInset.top - scrollView.contentInset.top
        let systemInsetBottom = scrollView.adjustedContentInset.bottom - scrollView.contentInset.bottom
        let visibleHeight = scrollView.bounds.height - systemInsetTop - systemInsetBottom
        let inset = max(0, (visibleHeight - scrollView.contentSize.height) / 2)
        guard scrollView.contentInset.top != inset || scrollView.contentInset.bottom != inset else { return }
        scrollView.contentInset.top = inset
        scrollView.contentInset.bottom = inset
    }
}

extension AVPlayerViewController {
    override open func viewDidLoad() {
        view.backgroundColor = .clear
    }
}
