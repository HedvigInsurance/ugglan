import SwiftUI

extension View {
    public func rotate(onAppear: Bool = false) -> some View {
        modifier(RotateViewModifier(onAppear: onAppear))
    }
}

private struct RotateViewModifier: ViewModifier {
    let onAppear: Bool
    @State private var vm = RotateViewModel()
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
@Observable
private class RotateViewModel {
    var angle: Double = 0
    @ObservationIgnored private var task: Task<(), any Error>?
    init() {
        animate()
    }

    func animate() {
        task?.cancel()
        task = Task {
            let animation = Animation.defaultSpring.speed(0.4)
            do {
                try await Task.sleep(for: .seconds(1))
                try Task.checkCancellation()
                withAnimation(animation) {
                    angle = 180
                }
                try await Task.sleep(for: .seconds(3))
                try Task.checkCancellation()
                withAnimation(animation) {
                    angle = 360
                }
                try await Task.sleep(for: .seconds(4))
                try Task.checkCancellation()
                angle = 0
            } catch {
                angle = 0
            }
        }
    }
}
