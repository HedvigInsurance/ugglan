import Foundation
import SwiftUI
import WebKit
import hCore
import hCoreUI

struct WebView: UIViewRepresentable {
    var url: URL
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            if (navigationAction.request.url?.host == "hedvig.com") {
                return .cancel
            }
            
            return .allow
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = context.coordinator
        
        let request = URLRequest(url: url)
        webview.load(request)
        
        return webview
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

public struct ZignsecWebview: View {
    public init() {}

    @PresentableStore var store: AuthenticationStore

    public var body: some View {
        PresentableStoreLens(
            AuthenticationStore.self,
            getter: { state in state.zignsecState.webviewUrl }
        ) { url in
            if let url = url {
                WebView(url: url)
            }
        }
    }
}
