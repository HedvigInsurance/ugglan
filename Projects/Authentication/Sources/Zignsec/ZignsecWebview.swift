import Foundation
import SwiftUI
import WebKit
import hCore
import hCoreUI

struct WebView: UIViewRepresentable {

    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

public struct ZignsecWebview: View {
    public init() {}

    @PresentableStore var store: AuthenticationStore

    public var body: some View {
        PresentableStoreLens(AuthenticationStore.self, getter: { state in state.zignsecState.webviewUrl }) { url in
            if let url = url {
                WebView(url: url)
            }
        }
    }
}
