import Foundation
import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    var style: UIActivityIndicatorView.Style

    public init(
        style: UIActivityIndicatorView.Style
    ) {
        self.style = style
    }

    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
    }
}

public struct WordmarkActivityIndicator: View {
    @State var rotating: Bool = false
    @State var hasEntered: Bool = false
    var size: Size

    public enum Size {
        case standard
        case small
    }

    public init(
        _ size: Size
    ) {
        self.size = size
    }

    var frameSize: CGFloat {
        switch size {
        case .standard:
            return 40
        case .small:
            return 20
        }
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2.0)
                .foregroundColor(hLabelColor.primary)

            hText("H", style: .largeTitle).minimumScaleFactor(0.1).padding(1.5)
                .rotationEffect(rotating ? Angle(degrees: 0) : Angle(degrees: -360))
                .animation(self.rotating ? .linear(duration: 1.5).repeatForever(autoreverses: false) : .default)
        }
        .frame(width: frameSize, height: frameSize)
        .scaleEffect(hasEntered ? 1 : 0.8)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.2), value: hasEntered)
        .onAppear {
            self.hasEntered = true
            self.rotating = true
        }
        .onDisappear {
            self.hasEntered = false
            self.rotating = false
        }
    }
}
