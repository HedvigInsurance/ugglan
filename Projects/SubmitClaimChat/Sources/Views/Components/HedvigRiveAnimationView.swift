@_spi(RiveExperimental) import RiveRuntime
import SwiftUI

struct HedvigRiveAnimationView: View {
    private enum Constants {
        static let darkFileName = "White"
        static let lightFileName = "Black"
        static let stateMachine = "State Machine 1"
        static let animatingInput = "Boolean 1"
        static let size: CGFloat = 100
    }

    @Binding var isAnimating: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var riveViewModel: RiveViewModel?

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
            let vm = makeViewModel()
            riveViewModel = vm
            vm.setInput(Constants.animatingInput, value: isAnimating)
        }
        .onChange(of: isAnimating) { newValue in
            riveViewModel?.setInput(Constants.animatingInput, value: newValue)
        }
        .onChange(of: colorScheme) { _ in
            riveViewModel = makeViewModel()
        }
    }

    private func makeViewModel() -> RiveViewModel {
        RiveViewModel(
            fileName: colorScheme == .dark ? Constants.darkFileName : Constants.lightFileName,
            stateMachineName: Constants.stateMachine
        )
    }
}
