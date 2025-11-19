import SwiftUI

extension View {
    public func rotate(onAppear: Bool = false) -> some View {
        modifier(RotateViewModifier(onAppear: onAppear))
    }
}

private struct RotateViewModifier: ViewModifier {
    let onAppear: Bool
    @StateObject private var vm = RotateViewModel()
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(vm.angle))
            .onAppear {
                if onAppear {
                    vm.animate()
                }
            }
    }
}

@MainActor
private class RotateViewModel: ObservableObject {
    @Published var angle: Double = 0
    private var task: Task<(), any Error>?
    init() {
        animate()
    }

    func animate() {
        task?.cancel()
        task = Task {
            let animation = Animation.defaultSpring.speed(0.4)
            try await Task.sleep(seconds: 1)
            try Task.checkCancellation()
            withAnimation(animation) {
                angle = 180
            }
            try await Task.sleep(seconds: 3)
            try Task.checkCancellation()
            withAnimation(animation) {
                angle = 360
            }
            try await Task.sleep(seconds: 4)
            try Task.checkCancellation()
            angle = 0
        }
    }
}
