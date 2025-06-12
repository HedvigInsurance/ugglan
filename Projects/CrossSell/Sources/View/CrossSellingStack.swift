import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingView: View {
    let withHeader: Bool
    @PresentableStore var store: CrossSellStore

    public init(
        withHeader: Bool
    ) {
        self.withHeader = withHeader
    }

    public var body: some View {
        VStack {
            PresentableStoreLens(
                CrossSellStore.self,
                getter: { state in
                    state.crossSells
                }
            ) { crossSells in
                if !crossSells.isEmpty {
                    CrosssSellStackView(crossSells: crossSells, withHeader: withHeader)
                }
            }
        }
        .task {
            store.send(.fetchCrossSell)
        }
    }
}

struct CrosssSellStackView: View {
    let crossSells: [CrossSell]
    let withHeader: Bool
    public var body: some View {
        if withHeader {
            hSection {
                VStack(spacing: .padding16) {
                    ForEach(crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell)
                            .transition(.slide)
                    }
                }
            }
            .withHeader(
                title: L10n.InsuranceTab.CrossSells.title,
                extraView: (
                    view: CrossSellingUnseenCircle().asAnyView,
                    alignment: .top
                )
            )
            .sectionContainerStyle(.transparent)
            .transition(.slide)
        } else {
            hSection {
                VStack(spacing: .padding16) {
                    ForEach(crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell)
                            .transition(.slide)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .transition(.slide)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingView(withHeader: true)
}
