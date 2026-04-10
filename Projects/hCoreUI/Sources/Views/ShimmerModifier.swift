import SwiftUI

public struct ShimmerTextModifier: ViewModifier {
    let isActive: Bool
    @State private var startPoint: UnitPoint = .init(x: -1.8, y: -1.2)
    @State private var endPoint: UnitPoint = .init(x: 0, y: -0.2)

    public init(isActive: Bool) {
        self.isActive = isActive
    }

    public func body(content: Content) -> some View {
        if isActive {
            content
                .opacity(0.4)
                .overlay(
                    content
                        .mask(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(1), .white.opacity(0.4)],
                                startPoint: startPoint,
                                endPoint: endPoint
                            )
                        )
                )
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: false)
                    ) {
                        startPoint = .init(x: 1, y: 1)
                        endPoint = .init(x: 2.8, y: 2.2)
                    }
                }
        } else {
            content
        }
    }
}

public struct Shimmer: ViewModifier {
    @State var isInitialState: Bool = true

    public init() {}
    public func body(content: Content) -> some View {
        content
            .mask {
                LinearGradient(
                    gradient: .init(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: 0.5) : .init(x: 1, y: 0.5)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0.5) : .init(x: 1.5, y: 0.5))
                )
            }
            .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear() {
                isInitialState = false
            }
    }
}

#Preview {
    VStack {
        RoundedRectangle(cornerRadius: .cornerRadiusL)
            .fill(hSurfaceColor.Opaque.primary)
            .frame(width: 100, height: 100)
            .modifier(Shimmer())
    }
}
