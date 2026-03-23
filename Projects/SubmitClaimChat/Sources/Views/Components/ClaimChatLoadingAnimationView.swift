@_spi(RiveExperimental) import RiveRuntime
import SwiftUI
import hCore
import hCoreUI

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
    @StateObject private var riveViewModel: RiveViewModel = {
        makeViewModel()
    }()
    @State private var animationTask: Task<Void, Error>?
    @State private var introAnimationPlayed = false
    @State private var animationOpacity: Double = 0

    init(isLoading: Binding<Bool>) {
        self._isLoading = isLoading
        if !isLoading.wrappedValue {
            animationOpacity = 1
        }
    }

    var body: some View {
        Group {
            riveViewModel.view()
                .opacity(isLoading ? animationOpacity : 1)
                .animation(.easeIn(duration: isLoading ? 0.5 : 0), value: animationOpacity)
        }
        .task {
            updateAnimation(isLoading: isLoading)
            await delay(Constants.introDelay * 2)
            animationOpacity = 1
        }
        .onChange(of: isLoading) { newValue in
            updateAnimation(isLoading: newValue)
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
                riveViewModel.play(animationName: RiveAnimationName.loadingIntro.rawValue)
                await delay(Constants.introToLoopTransitionDelay)
                riveViewModel.play(animationName: RiveAnimationName.loading.rawValue)
                introAnimationPlayed = true
            } else if introAnimationPlayed {
                riveViewModel.stop()
                riveViewModel.play(animationName: RiveAnimationName.loadingOutro.rawValue)
            }
        }
    }

    private static func makeViewModel() -> RiveViewModel {
        RiveViewModel(
            fileName: UITraitCollection.current.userInterfaceStyle == .dark
                ? Constants.darkModeFile : Constants.lightModeFile,
            in: Bundle(for: Router.self),
            animationName: RiveAnimationName.idle.rawValue,
            autoPlay: false
        )
    }
}
