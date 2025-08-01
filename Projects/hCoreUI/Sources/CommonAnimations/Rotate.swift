import SwiftUI

extension View {
    public func rotate() -> some View {
        modifier(RotateViewModifier())
    }
}

private struct RotateViewModifier: ViewModifier {
    @StateObject private var vm = RotateViewModel()
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(vm.angle))
    }
}

@MainActor
private class RotateViewModel: ObservableObject {
    @Published var angle: Double = 0

    init() {
        Task {
            let animation = Animation.defaultSpring.speed(0.4)
            try await Task.sleep(nanoseconds: 1_000_000_000)
            withAnimation(animation) {
                angle = 180
            }
            try await Task.sleep(nanoseconds: 3_000_000_000)
            try Task.checkCancellation()
            withAnimation(animation) {
                angle = 360
            }
            try await Task.sleep(nanoseconds: 4_000_000_000)
            try Task.checkCancellation()
            angle = 0
        }
    }
}
