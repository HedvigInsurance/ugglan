@_spi(RiveExperimental) import RiveRuntime
import SwiftUI
import hCore

struct ClaimChatLoadingAnimationView: View {
    enum Constants {
        static let animationSize: CGFloat = 36
        fileprivate static let darkModeFile = "HedvigLoaderDark"
        fileprivate static let lightModeFile = "HedvigLoaderLight"
        fileprivate static let introDelay: TimeInterval = 0.1
        fileprivate static let introToLoopTransitionDelay: TimeInterval = 1
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
    @State private var introAnimationPlayed = false

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
                updateAnimation(isLoading: isLoading)
            }
        }
        .onChange(of: isLoading) { newValue in
            updateAnimation(isLoading: newValue)
        }
        .onChange(of: colorScheme) { _ in
            animationTask?.cancel()
            animationTask = nil
            introAnimationPlayed = false
            riveViewModel = makeViewModel()
            updateAnimation(isLoading: isLoading)
        }
        .onDisappear {
            animationTask?.cancel()
            animationTask = nil
        }
    }

    private func updateAnimation(isLoading loading: Bool) {
        animationTask?.cancel()
        animationTask = Task {
            if loading && !introAnimationPlayed {
                await delay(Constants.introDelay)
                riveViewModel?.play(animationName: RiveAnimationName.loadingIntro.rawValue)
                await delay(Constants.introToLoopTransitionDelay)
                riveViewModel?.play(animationName: RiveAnimationName.loading.rawValue)
                introAnimationPlayed = true
            } else if introAnimationPlayed {
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
