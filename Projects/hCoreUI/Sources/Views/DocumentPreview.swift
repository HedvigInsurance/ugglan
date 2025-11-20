import AVKit
import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import WebKit
import hCore

@MainActor
public class DocumentPreviewModel: NSObject, ObservableObject {
    let type: DocumentPreviewType
    let webView = WKWebView()
    let player: AVPlayer?
    weak var vc: UIViewController? {
        didSet {
            guard type.name != nil else { return }
            setupShareButton()
        }
    }
    @Published var isLoading = true
    @Published var error: String?
    @Published var contentHeight: CGFloat = 0
    @Published var offset: CGFloat = 0
    @Published var opacity: Double = 0

    var contentSizeCancellable: AnyCancellable?
    private var temporaryFileURL: URL?

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
        let color = UIColor { trait in
            hTextColor.Opaque.primary
                .colorFor(
                    trait.userInterfaceStyle == .light ? .light : .dark,
                    .base
                )
                .color.uiColor()
        }
        let image = UIImage(systemName: "square.and.arrow.up")?
            .withTintColor(color, renderingMode: .alwaysTemplate)
        let barButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(share(sender:))
        )
        vc?.navigationItem.rightBarButtonItem = barButtonItem
    }

    @objc func share(sender: UIBarButtonItem) {
        Task {
            do {
                let data = try await fetchData()
                guard let name = type.name else { return }
                let fileURL = try createTemporaryFile(data: data, name: name, extension: type.mimeType.name)
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

    private func createTemporaryFile(data: Data, name: String, extension: String) throws -> URL {
        cleanupTemporaryFile()

        let contentURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(name)
            .appendingPathExtension(`extension`)
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
    @ObservedObject var vm: DocumentPreviewModel
    public init(vm: DocumentPreviewModel) {
        self.vm = vm
    }

    public var body: some View {
        GeometryReader { _ in
            ZStack {
                BackgroundBlurView()
                    .ignoresSafeArea()
                if let player = vm.player {
                    VideoPlayer(player: player)
                } else {
                    DocumentPreviewWebView(documentPreviewModel: vm)
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
        }
        .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
            if vm?.vc != vc {
                vm?.vc = vc
            }
        }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.contentSizeCancellable = nil
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
        vm.contentSizeCancellable = vm.webView.scrollView.publisher(for: \.contentSize)
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .sink(receiveValue: { @MainActor [weak vm] value in
                withAnimation(.none) {
                    vm?.contentHeight = value.height
                }
            })
        vm.webView.scrollView.minimumZoomScale = 1
        vm.webView.backgroundColor = .clear
        vm.webView.scrollView.backgroundColor = .clear
        vm.webView.isOpaque = false
        vm.webView.viewController?.view.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak vm] in
            vm?.webView.viewController?.view.backgroundColor = .brand(.primaryBackground()).withAlphaComponent(0.55)
        }
        return vm.webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}
}

extension AVPlayerViewController {
    override open func viewDidLoad() {
        view.backgroundColor = .clear
    }
}
