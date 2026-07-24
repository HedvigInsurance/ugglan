import SwiftUI
import hCore
import hCoreUI

struct OnboardingWelcomeScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    @State private var showBadge = false
    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    logo
                    VStack(spacing: .padding4) {
                        hText("Welcome to Hedvig", style: .body1)  // TODO: L10n
                            .accessibilityAddTraits(.isHeader)
                        hText("Follow the steps to get started with your insurance", style: .body1)  // TODO: L10n
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                hButton(.large, .primary, content: .init(title: "Get started")) {  // TODO: L10n
                    vm.advance(after: .welcome)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .task {
            await delay(2)
            showBadge = true
        }
    }

    private var logo: some View {
        ZStack(alignment: .topTrailing) {
            hCoreUIAssets.bigPillowBlack.view
                .resizable()
                .frame(width: 128, height: 128)
            if showBadge {
                Circle()
                    .fill(hSignalColor.Red.element)
                    .frame(width: 38, height: 38)
                    .overlay {
                        hText("1", style: .heading1)
                            .foregroundColor(hTextColor.Opaque.white)
                    }
                    .offset(x: .padding6, y: -.padding6)
                    .transition(.scale.animation(.bouncy))
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    OnboardingWelcomeScreen()
        .environmentObject(OnboardingNavigationViewModel())
}
