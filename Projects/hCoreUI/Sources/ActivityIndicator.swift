import Foundation
import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    var isAnimating: Bool

    public init(
        isAnimating: Bool
    ) {
        self.isAnimating = isAnimating
    }

    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
