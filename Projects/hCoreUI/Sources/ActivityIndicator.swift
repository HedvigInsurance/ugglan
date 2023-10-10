import Foundation
import SwiftUI

private struct EnvironmentUseDarkColor: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var useDarkColor: Bool {
        get { self[EnvironmentUseDarkColor.self] }
        set { self[EnvironmentUseDarkColor.self] = newValue }
    }
}

extension View {
    public var useDarkColor: some View {
        self.environment(\.useDarkColor, true)
    }
}

public struct ActivityIndicator: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.userInterfaceLevel) var userInterfaceLevel
    var style: UIActivityIndicatorView.Style
    var color: any hColor

    public init(
        style: UIActivityIndicatorView.Style,
        color: any hColor
    ) {
        self.style = style
        self.color = color
    }

    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
        uiView.color = UIColor(self.color.colorFor(colorScheme, userInterfaceLevel).color)
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
                .foregroundColor(hTextColor.primary)

            hText("H", style: .title1).minimumScaleFactor(0.1).padding(1.5)
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

public struct DotsActivityIndicator: View {
    @State var animate: Bool = false
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

    var dotSize: CGFloat {
        switch size {
        case .standard:
            return 6
        case .small:
            return 3
        }
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            PulsingCircle(index: 0).frame(width: dotSize, height: dotSize)
            Color.clear.frame(width: dotSize)
            PulsingCircle(index: 1).frame(width: dotSize, height: dotSize)
            Color.clear.frame(width: dotSize)
            PulsingCircle(index: 2).frame(width: dotSize, height: dotSize)
        }
        .onAppear {
            self.animate = true
        }
        .onDisappear {
            self.animate = false
        }
    }
}

private struct PulsingCircle: View {
    @Environment(\.useDarkColor) var useDarkColor
    let totalNumber: CGFloat = 3
    let duration: CGFloat = 0.5
    let index: CGFloat
    @State var animate: Bool = false

    public var body: some View {
        Circle()
            .fill(getFillColor)
            .opacity(animate ? 0.4 : 1)
            .onAppear {
                setAnimation()
            }
    }

    @hColorBuilder
    var getFillColor: some hColor {
        if useDarkColor {
            hTextColor.primary
        } else {
            hTextColor.negative
        }
    }

    private func setAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * index) {
            //            withAnimation(.interpolatingSpring(stiffness: 170, damping: 15)) {
            withAnimation(.easeInOut(duration: duration)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeInOut(duration: duration)) {
                    animate = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration * (totalNumber - index - 1)) {
                    setAnimation()
                }
            }
        }
    }
}

struct DotsActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DotsActivityIndicator(.standard).background(Color.black)
    }
}
