import Addons
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingScreen: View {
    @StateObject private var vm = CrossSellingScreenViewModel()

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: .padding24) {
                CrossSellingStack(withHeader: false)
                if let banner = vm.addonBannerModel {
                    AddonCardView(
                        openAddon: {
                            /* TODO: ADD */
                        },
                        addon: banner
                    )
                }
            }
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.crossSellTitle, subTitle: L10n.crossSellSubtitle)
        .onAppear {
            Task {
                await vm.getAddonBanner()
            }
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
        return CrossSellingScreen()
    }
}
