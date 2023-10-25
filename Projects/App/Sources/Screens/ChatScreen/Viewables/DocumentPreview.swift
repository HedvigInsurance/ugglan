import Presentation
import SwiftUI
import WebKit
import hCore

struct DocumentPreview: UIViewRepresentable {
    // 1

    let data: Data?
    let mimeType: String?
    let url: URL?
    let webView = WKWebView()
    init(data: Data, mimeType: String) {
        self.data = data
        self.mimeType = mimeType
        url = nil
    }

    init(url: URL) {
        self.data = nil
        self.mimeType = nil
        self.url = url
    }
    // 2
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.backgroundColor = .brand(.primaryBackground())
        if let data, let mimeType {
            webView.load(data, mimeType: mimeType, characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        } else if let url {
            let request = URLRequest(url: url)
            webView.load(request)

        }
    }
}

extension DocumentPreview {
    var journey: some JourneyPresentation {
        return HostingJourney(rootView: self, style: .detented(.large)).withDismissButton
    }
}
