import Addons
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingScreen: View {
    @StateObject private var vm = CrossSellingScreenViewModel()
    @EnvironmentObject private var router: Router
    let addonCardOnClick: () -> Void

    public init(
        addonCardOnClick: @escaping () -> Void
    ) {
        self.addonCardOnClick = addonCardOnClick
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding24) {
                CrossSellingStack(withHeader: false)
                addonBanner
            }
            .padding(.bottom, .padding8)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.crossSellTitle, subTitle: L10n.crossSellSubtitle)
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButton(type: .ghost) {
                    router.dismiss()
                } content: {
                    hText(L10n.generalCloseButton)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .onAppear {
            Task {
                await vm.getAddonBanner()
            }
        }
    }

    @ViewBuilder
    private var addonBanner: some View {
        if let banner = vm.addonBannerModel {
            hSection {
                AddonCardView(
                    openAddon: {
                        addonCardOnClick()
                    },
                    addon: banner
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

@MainActor
public class CrossSellingScreenViewModel: ObservableObject {
    @Inject var service: CrossSellClient
    @Published var addonBannerModel: AddonBannerModel?

    func getAddonBanner() async {
        do {
            let data = try await service.getAddonBannerModel(source: .crossSell)
            withAnimation {
                self.addonBannerModel = data
            }
        } catch {
            withAnimation {
                self.addonBannerModel = nil
            }
        }
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen(addonCardOnClick: {})
    }
}
