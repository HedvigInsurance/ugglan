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
                    CrosssSellStackComponent(crossSells: crossSells, withHeader: withHeader)
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
