import CrossSell
import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct OnboardingCrossSellScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    var body: some View {
        hForm {
            CrossSellStackComponent(crossSells: vm.crossSells, discountAvailable: false, withHeader: false)
                .fixedSize(horizontal: false, vertical: true)
        }
        .hFormTitle(
            title: .init(.small, .body1, "Get bundle discount", alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                "You get a 15% bundle discount when you have two or more insurances with us",
                alignment: .leading
            )
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                hButton(.large, .primary, content: .init(title: "Continue to app")) {  // TODO: L10n
                    vm.advance(after: .crossSell(vm.crossSells))
                }
                .accessibilityLabel("Continue to app")  // TODO: L10n
            }
            .sectionContainerStyle(.transparent)
        }
        .task {
            await vm.fetchCrossSells()
        }
    }
}

private struct OnboardingCrossSellRow: View {
    let crossSell: CrossSell

    var body: some View {
        HStack(spacing: .padding16) {
            KFImage(crossSell.imageUrl)
                .placeholder {
                    hCoreUIAssets.bigPillowHome.view
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                .fade(duration: 0.25)
                .resizable()
                .frame(width: 48, height: 48)
                .aspectRatio(contentMode: .fill)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: .padding2) {
                hText(crossSell.title, style: .body1)
                hText(crossSell.description, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
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
