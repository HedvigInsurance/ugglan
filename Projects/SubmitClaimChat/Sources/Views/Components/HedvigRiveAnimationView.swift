@_spi(RiveExperimental) import RiveRuntime
import SwiftUI
import hCore

struct ClaimChatLoadingAnimationView: View {
    enum Constants {
        static let animationSize: CGFloat = 36
        fileprivate static let darkModeFile = "HedvigLoaderDark"
        fileprivate static let lightModeFile = "HedvigLoaderLight"
        fileprivate static let introDelay: TimeInterval = 0.1
        fileprivate static let loopDelay: TimeInterval = 1
    }

    private enum RiveAnimationName: String {
        case idle = "Idle"
        case loading = "Loading"
        case loadingIntro = "Loading intro"
        case loadingOutro = "Loading outro"
    }

    @Binding var isLoading: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var riveViewModel: RiveViewModel?
    @State private var animationTask: Task<Void, Error>?
    @State private var initialAnimationDone = false

    var body: some View {
        Group {
            if let riveViewModel {
                riveViewModel.view()
            } else {
                Color.clear
            }
        }
        .task {
            if riveViewModel == nil {
                riveViewModel = makeViewModel()
                playAnimations(loading: isLoading)
            }
        }
        .onChange(of: isLoading) { newValue in
            playAnimations(loading: newValue)
        }
        .onChange(of: colorScheme) { _ in
            initialAnimationDone = false
            riveViewModel = makeViewModel()
            playAnimations(loading: isLoading)
        }
    }

    private func playAnimations(loading: Bool) {
        animationTask?.cancel()
        animationTask = Task {
            if loading && !initialAnimationDone {
                await delay(Constants.introDelay)
                riveViewModel?.play(animationName: RiveAnimationName.loadingIntro.rawValue)
                await delay(Constants.loopDelay)
                try Task.checkCancellation()
                riveViewModel?.play(animationName: RiveAnimationName.loading.rawValue)
                initialAnimationDone = true
            } else if initialAnimationDone {
                riveViewModel?.stop()
                riveViewModel?.play(animationName: RiveAnimationName.loadingOutro.rawValue)
            }
        }
    }

    private func makeViewModel() -> RiveViewModel {
        RiveViewModel(
            fileName: colorScheme == .dark ? Constants.darkModeFile : Constants.lightModeFile,
            animationName: RiveAnimationName.idle.rawValue,
            autoPlay: false
        )
    }
}
