import SwiftUI
import WebKit
import hCore
import hCoreUI

/// Renders an email's HTML read-only, sized to its content so the screen does the scrolling.
///
/// Links and buttons are inert: every navigation after the initial load is cancelled, JavaScript and link
/// previews are off, and the injected stylesheet greys links and buttons out and drops their pointer events.
struct EmailWebView: View {
    let html: String

    @Environment(\.colorScheme) private var colorScheme
    /// Read so the document is rebuilt, at the new scaled size, when the text size changes.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var contentHeight: CGFloat = .padding40
    /// False until WebKit has finished the first load, so the loader stays up instead of a blank card.
    @State private var isRendered = false

    var body: some View {
        ZStack {
            webView
                .frame(height: isRendered ? contentHeight : MessageBodyLoader.height, alignment: .top)
                .opacity(isRendered ? 1 : 0)
            if !isRendered {
                MessageBodyLoader()
                    .transition(.opacity)
            }
        }
        .messagesAnimation(value: isRendered)
    }

    private var webView: some View {
        EmailWebViewRepresentable(
            document: EmailDocument.make(
                body: html,
                colorScheme: colorScheme,
                scale: UIFontMetrics(forTextStyle: .body)
                    .scaledValue(
                        for: 1,
                        compatibleWith: UITraitCollection(
                            preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize)
                        )
                    )
            ),
            contentHeight: $contentHeight,
            isRendered: $isRendered
        )
    }
}

private struct EmailWebViewRepresentable: UIViewRepresentable {
    let document: String
    @Binding var contentHeight: CGFloat
    @Binding var isRendered: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(contentHeight: $contentHeight, isRendered: $isRendered)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        configuration.dataDetectorTypes = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        context.coordinator.observeContentSize(of: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.contentHeight = $contentHeight
        context.coordinator.isRendered = $isRendered
        guard context.coordinator.loadedDocument != document else { return }
        context.coordinator.loadedDocument = document
        context.coordinator.isInitialLoadPending = true
        webView.loadHTMLString(document, baseURL: nil)
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        coordinator.contentSizeObservation = nil
        webView.navigationDelegate = nil
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        var contentHeight: Binding<CGFloat>
        var isRendered: Binding<Bool>
        var loadedDocument: String?
        var isInitialLoadPending = false
        var contentSizeObservation: NSKeyValueObservation?

        init(contentHeight: Binding<CGFloat>, isRendered: Binding<Bool>) {
            self.contentHeight = contentHeight
            self.isRendered = isRendered
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Measure once more after layout so the card opens at the email's full height.
            let height = webView.scrollView.contentSize.height
            if height.isFinite, height > 0 {
                contentHeight.wrappedValue = height
            }
            isRendered.wrappedValue = true
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isRendered.wrappedValue = true
        }

        func observeContentSize(of webView: WKWebView) {
            contentSizeObservation = webView.scrollView.observe(\.contentSize, options: [.new]) {
                [weak self] _, change in
                guard let height = change.newValue?.height, height.isFinite, height > 0 else { return }
                Task { @MainActor [weak self] in
                    guard let self, abs(self.contentHeight.wrappedValue - height) > 0.5 else { return }
                    self.contentHeight.wrappedValue = height
                }
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            // Only the document handed to `loadHTMLString` may load; links, form posts, redirects and
            // iframes are all refused. Images and stylesheets are subresources and never come through here.
            let isInitialLoad =
                isInitialLoadPending
                && navigationAction.navigationType == .other
                && navigationAction.targetFrame?.isMainFrame == true
            if isInitialLoad {
                isInitialLoadPending = false
                return .allow
            }
            return .cancel
        }
    }
}

/// Wraps the email body in a document styled with hCoreUI colours for the current colour scheme.
@MainActor
enum EmailDocument {
    /// `scale` is the Dynamic Type multiplier applied to every font size.
    static func make(body: String, colorScheme: ColorScheme, scale: CGFloat = 1) -> String {
        let text = css(hTextColor.Opaque.primary, colorScheme)
        let disabledText = css(hTextColor.Opaque.disabled, colorScheme)
        let disabledFill = css(hFillColor.Opaque.disabled, colorScheme)
        return """
            <!DOCTYPE html>
            <html>
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
            <meta name="color-scheme" content="light dark">
            <style>
            \(fontFace)
            :root { color-scheme: \(colorScheme == .dark ? "dark" : "light"); }
            html { font-size: \(Int(18 * scale))px; }
            html, body {
                margin: 0; padding: 0;
                background: transparent;
                color: \(text);
                font-family: 'HedvigLetters-Standard', -apple-system, sans-serif;
                font-weight: 400;
                line-height: 1.35;
                -webkit-text-size-adjust: 100%;
                overflow-wrap: break-word;
            }
            h1, h2, h3, h4, h5, h6, strong, b { font-weight: 400; }
            h1 { font-size: 1.78rem; line-height: 1.2; margin: 0 0 24px; }
            h2 { font-size: 1.33rem; margin: 0 0 16px; }
            p { margin: 0 0 24px; }
            img { max-width: 100%; height: auto; }
            table { max-width: 100% !important; }
            a, a * {
                color: \(disabledText) !important;
                pointer-events: none !important;
                -webkit-touch-callout: none;
            }
            button, .button, a.button, input[type="button"], input[type="submit"] {
                display: block;
                width: 100%;
                box-sizing: border-box;
                margin: 0 0 8px;
                padding: 16px;
                border: none;
                border-radius: 999px;
                background: \(disabledFill) !important;
                color: \(disabledText) !important;
                font: inherit;
                text-align: center;
                text-decoration: none;
                pointer-events: none !important;
            }
            body > :last-child { margin-bottom: 0; }
            </style>
            </head>
            <body>\(body)</body>
            </html>
            """
    }

    private static func css(_ color: some hColor, _ colorScheme: ColorScheme) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.colorFor(colorScheme, .base).color.uiColor()
            .getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "rgba(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)), \(alpha))"
    }

    /// The web content process can't see fonts registered in the app, so the Hedvig font is inlined.
    private static let fontFace: String = {
        guard
            let url = Bundle(for: hNavigationBaseController.self)
                .url(forResource: "HedvigLetters-Standard", withExtension: "otf"),
            let data = try? Data(contentsOf: url)
        else { return "" }
        return """
            @font-face {
                font-family: 'HedvigLetters-Standard';
                src: url(data:font/otf;base64,\(data.base64EncodedString())) format('opentype');
                font-weight: 400;
            }
            """
    }()
}
