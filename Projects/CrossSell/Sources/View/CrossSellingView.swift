import AppStateContainer
import SwiftUI
import hCore

public struct CrossSellingView: View {
    let withHeader: Bool
    @AppObservedObject var store: CrossSellStore

    public init(
        withHeader: Bool
    ) {
        self.withHeader = withHeader
    }

    public var body: some View {
        VStack {
            if let crossSells = store.crossSells, !crossSells.others.isEmpty {
                CrossSellStackComponent(
                    crossSells: crossSells.others,
                    discountAvailable: crossSells.discountAvailable,
                    withHeader: withHeader
                )
            }
        }
        .task {
            await store.fetchCrossSell()
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingView(withHeader: true)
}
