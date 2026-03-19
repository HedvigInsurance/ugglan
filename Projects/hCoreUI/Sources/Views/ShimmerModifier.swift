import SwiftUI

public struct ShimmerModifier: ViewModifier {
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
                        .easeInOut(duration: 1.5)
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
