import Addons
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingScreen: View {
    @PresentableStore var store: CrossSellStore
    let crossSell: CrossSell
    let style: TransitionType

    public init(
        crossSellInfo: CrossSellInfo,
        style: TransitionType
    ) {
        self.crossSell =
            crossSellInfo.crossSell
            ?? .init(
                title: "Accident Insurance",
                description: "Help when you need it the most",
                type: .accident
            )
        self.style = style
        Task {
            try await Task.sleep(nanoseconds: 200_000_000)
            crossSellInfo.logCrossSellEvent()
        }
    }

    public var body: some View {
        ZStack {
            BackgroundView()
                .edgesIgnoringSafeArea(.all)
            VStack {
                CrossSellBannerComponent()
                    .ignoresSafeArea(edges: .top)
                hForm {
                    VStack(spacing: .padding48) {
                        CrossSellPillowComponent(crossSell: crossSell)

                        if style != .pageSheet {
                            CrossSellButtonComponent()
                        }
                    }
                }
                .hFormContentPosition(.center)
                .hFormAttachToBottom {
                    if style == .pageSheet {
                        CrossSellButtonComponent()
                    } else {
                        CrossSellingStack(withHeader: false)
                    }
                }
                .task {
                    store.send(.fetchAddonBanner)
                }
            }
        }
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen(crossSellInfo: .init(type: .home), style: .detent(style: []))
    }
}
