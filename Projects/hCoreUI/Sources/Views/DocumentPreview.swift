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
    @Published var opacity: Double = 0

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
        case let .data(data, mimeType):
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
            case let .data(data, _):
                return "\(data.count)"
            }
        }

        case url(url: URL, mimeType: MimeType)
        case data(data: Data, mimeType: MimeType)
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
        .introspect(.viewController, on: .iOS(.v13...)) { vc in
            vm.vc = vc
        }
        .embededInNavigation(
            options: [.navigationBarHidden],
            tracking: self
        )
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
