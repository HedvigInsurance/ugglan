import CrossSell
import SwiftUI
import hCore
import hCoreUI

struct OnboardingCrossSellScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    var body: some View {
        hForm {
            CrossSellStackComponent(crossSells: vm.crossSells)
                .fixedSize(horizontal: false, vertical: true)
        }
        .hFormTitle(
            title: .init(.small, .body1, L10n.onboardingCrossSellTitle, alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                L10n.onboardingCrossSellSubtitle,
                alignment: .leading
            )
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.onboardingContinueToAppButton)) {
                    vm.advance(after: .crossSell(vm.crossSells))
                }
                .accessibilityLabel(L10n.onboardingContinueToAppButton)
            }
            .sectionContainerStyle(.transparent)
        }
        .task {
            await vm.fetchCrossSells()
        }
    }
}

#Preview {
    let viewModel = OnboardingNavigationViewModel()
    viewModel.steps = [
        .crossSell(
            [
                .init(
                    id: "1",
                    title: "title",
                    description: "desc",
                    buttonTitle: "See price",
                    webActionURL: "",
                    imageUrl: URL(
                        string:
                            "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F832x832%2Ff8c6668c24%2Frental-pillow-832x832px.png&w=640&q=75"
                    ),
                    buttonDescription: "desc"
                ),
                .init(
                    id: "2",
                    title: "title 2",
                    description: "desc 2",
                    buttonTitle: "See price",
                    webActionURL: "",
                    imageUrl: URL(
                        string:
                            "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F832x832%2Ff8c6668c24%2Frental-pillow-832x832px.png&w=640&q=75"
                    ),
                    buttonDescription: "desc"
                ),
            ]
        )
    ]
    return OnboardingCrossSellScreen()
        .environmentObject(viewModel)
}
