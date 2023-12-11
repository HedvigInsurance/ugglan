import Presentation
import SwiftUI
import WebKit
import hCore

public struct DocumentPreview: UIViewRepresentable {
    let data: Data?
    let mimeType: String?
    let url: URL?
    let webView = WKWebView()
    let sss = SSS()
    public init(data: Data, mimeType: String) {
        self.data = data
        self.mimeType = mimeType
        url = nil
    }

    public init(url: URL) {
        self.data = nil
        self.mimeType = nil
        self.url = url
    }

    public func makeUIView(context: Context) -> WKWebView {
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = sss
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        webView.backgroundColor = .brand(.primaryBackground())
        webView.scrollView.backgroundColor = .brand(.primaryBackground())
        webView.isOpaque = false
        webView.viewController?.view.backgroundColor = .brand(.primaryBackground())
        if let data, let mimeType {
            webView.load(data, mimeType: mimeType, characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        } else if let url {
            let request = URLRequest(url: url)
            webView.load(request)

        }
    }
}

extension DocumentPreview {
    public var journey: some JourneyPresentation {
        return HostingJourney(rootView: self, style: .detented(.large)).withDismissButton
    }
}

class SSS: NSObject, WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        let ss = navigationResponse.response.mimeType
        if navigationResponse.canShowMIMEType {
            decisionHandler(.allow)
        } else {
            if #available(iOS 14.5, *) {
                decisionHandler(.download)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    //    func webView(_ webView: WKWebView,
    //            decidePolicyFor navigationResponse: WKNavigationResponse,
    //            decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    //
    //        if let mimeType = navigationResponse.response.mimeType {
    //            // do some thing with the MIME type
    //        } else {
    //            // response has no MIME type, do some special handling
    //        }
    //        decisionHandler(.allow)
    //    }
}
