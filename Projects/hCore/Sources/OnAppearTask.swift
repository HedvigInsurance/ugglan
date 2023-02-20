import Foundation
import SwiftUI

struct OnAppearTaskViewModifier: ViewModifier {
    var work: () async -> Void
    @State var task: AnyTask?

    func body(content: Content) -> some View {
        content.onAppear {
            task =
                Task {
                    await work()
                }
                .eraseToAnyTask
        }
        .onDisappear {
            task?.cancel()
        }
    }
}

extension View {
    public func taskOnAppear(
        _ task: @escaping () async -> Void
    ) -> some View {
        self.modifier(OnAppearTaskViewModifier(work: task))
    }
}
