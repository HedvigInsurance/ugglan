@_spi(RiveExperimental) import RiveRuntime
import SwiftUI
import hCore

struct HedvigRiveAnimationView: View {
    private enum Constants {
        static let darkFileName = "White"
        static let lightFileName = "Black"
        static let size: CGFloat = 100
    }

    private enum Animation: String {
        case idle = "Idle"
        case loading = "Loading"
        case loadingIntro = "Loading intro"
        case loadingOutro = "Loading outro"
    }

    @Binding var isAnimating: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var riveViewModel: RiveViewModel?
    @State private var animationTask: Task<Void, Error>?

    var body: some View {
        Group {
            if let riveViewModel {
                riveViewModel.view()
            } else {
                Color.clear
            }
        }
        .frame(width: Constants.size, height: Constants.size)
        .task {
            if riveViewModel == nil {
                riveViewModel = makeViewModel()
                playAnimations(animating: isAnimating)
            }
        }
        .onChange(of: isAnimating) { newValue in
            playAnimations(animating: newValue)
        }
    }

    private func playAnimations(animating: Bool) {
        animationTask?.cancel()
        animationTask = Task { [weak riveViewModel] in
            if animating {
                await delay(0.1)
                riveViewModel?.play(animationName: Animation.loadingIntro.rawValue)
                await delay(1)
                try Task.checkCancellation()
                riveViewModel?.play(animationName: Animation.loading.rawValue)
            } else {
                riveViewModel?.stop()
                riveViewModel?.play(animationName: Animation.loadingOutro.rawValue)
            }
        }
    }

    private func makeViewModel() -> RiveViewModel {
        RiveViewModel(
            fileName: colorScheme == .dark ? Constants.darkFileName : Constants.lightFileName,
            animationName: Animation.idle.rawValue,
            autoPlay: false
        )
    }
}
