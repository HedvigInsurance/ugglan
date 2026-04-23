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

public struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    public init() {}
    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.4), location: -1),
                        .init(color: .black.opacity(0.7), location: 0.3 + phase * 0.4),
                        .init(color: .black.opacity(0.4), location: 2),
                    ],
                    startPoint: .init(x: -0.5 + phase, y: 0.5),
                    endPoint: .init(x: 0.3 + phase, y: 0.5)
                )
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4)
                        .repeatForever(autoreverses: true)
                ) {
                    phase = 1.0
                }
            }
    }
}

#Preview {
    VStack {
        hSection {
            RoundedRectangle(cornerRadius: .cornerRadiusL)
                .fill(hSurfaceColor.Opaque.primary)
                .frame(width: 100, height: 100)
                .modifier(Shimmer())
        }
        .colorScheme(.light)
        hSection {
            RoundedRectangle(cornerRadius: .cornerRadiusL)
                .fill(hSurfaceColor.Opaque.primary)
                .frame(width: 100, height: 100)
                .modifier(Shimmer())
        }
        .colorScheme(.dark)
    }
    .sectionContainerStyle(.transparent)
}
