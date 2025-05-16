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
    weak var vc: UIViewController?
    @Published var isLoading = true
    @Published var error: String?
    @Published var contentHeight: CGFloat = 0
    @Published var offset: CGFloat = 0
    @Published var opacity: CGFloat = 0

    var contentSizeCancellable: AnyCancellable?
    public init(type: DocumentPreviewType) {
        self.type = type

        switch type {
        case let .url(url, mimeType):
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

    func loadURL() {
        withAnimation {
            isLoading = true
            error = nil
        }
        switch type {
        case let .url(url, _):
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

    public enum DocumentPreviewType: Equatable, Identifiable {
        public var id: String {
            switch self {
            case let .url(url, _):
                return url.absoluteString
            case .data(let data, _):
                return "\(data.count)"
            }
        }

        case url(url: URL, mimeType: MimeType)
        case data(data: Data, mimeType: MimeType)
        var url: URL? {
            switch self {
            case .url(let url, _):
                return url
            case .data:
                return nil
            }
        }
    }

}

public struct DocumentPreview: View {
    @ObservedObject var vm: DocumentPreviewModel
    public init(vm: DocumentPreviewModel) {
        self.vm = vm
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                BackgroundBlurView()
                    .ignoresSafeArea()
                if let player = vm.player {
                    VideoPlayer(player: player)
                } else {
                    DocumentPreviewWebView(documentPreviewModel: vm)
                        .frame(maxHeight: .infinity)
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
        .introspect(.viewController, on: .iOS(.v13...)) { vc in
            vm.vc = vc
        }
        .embededInNavigation(options: [.navigationBarHidden], tracking: self)
    }
}
extension DocumentPreview: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: DocumentPreview.self)
    }

}

extension DocumentPreviewModel: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        withAnimation {
            isLoading = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.contentSizeCancellable = nil
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
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .sink(receiveValue: { @MainActor [weak vm] value in
                switch vm?.type {
                case .url:
                    withAnimation {
                        vm?.contentHeight = value.height
                    }
                case .data:
                    if value.height > 0 {
                        withAnimation(.defaultSpring) {
                            vm?.contentHeight = value.height
                            vm?.opacity = 1
                        }
                    }
                case .none:
                    break
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

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

extension AVPlayerViewController {
    open override func viewDidLoad() {
        view.backgroundColor = .clear
    }
}
