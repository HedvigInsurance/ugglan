import Combine
import PresentableStore
import SwiftUI
import hCore

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
                if let crossSells {
                    if !crossSells.others.isEmpty {
                        CrossSellStackComponent(
                            crossSells: crossSells.others,
                            discountAvailable: crossSells.discountAvailable,
                            withHeader: withHeader
                        )
                    }
                }
            }
        }
        .task {
            store.send(.fetchCrossSell)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingView(withHeader: true)
}
