@_spi(RiveExperimental) import RiveRuntime
import SwiftUI
import hCore

struct HedvigRiveAnimationView: View {
    private enum Constants {
        static let darkFileName = "White"
        static let lightFileName = "Black"
        static let size: CGFloat = 100
    }

    @Binding var isAnimating: Bool
    @StateObject private var riveViewModel: RiveViewModel

    init(isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating

        let model = RiveViewModel(
            fileName: Constants.lightFileName,
            animationName: "Idle",
            autoPlay: false
        )
        self._riveViewModel = StateObject(wrappedValue: model)
    }

    var body: some View {
        Group {
            riveViewModel.view()
        }
        .frame(width: Constants.size, height: Constants.size)
        .task {
            print("ANIMATION PLAYED TASK")
            playAnimations(animating: isAnimating)
        }
        .onChange(of: isAnimating) { newValue in
            print("ANIMATION PLAYED CHANGE")
            playAnimations(animating: newValue)
        }
    }
    @State var task: Task<(), Error>? = nil
    private func playAnimations(animating: Bool) {
        task?.cancel()
        task = Task { [weak riveViewModel] in
            if animating {
                await delay(0.1)
                riveViewModel?.play(animationName: "Loading intro")
                await delay(1)
                try Task.checkCancellation()
                riveViewModel?.play(animationName: "Loading")
            } else {
                riveViewModel?.stop()
                riveViewModel?.play(animationName: "Loading outro")
            }
        }
    }
}
