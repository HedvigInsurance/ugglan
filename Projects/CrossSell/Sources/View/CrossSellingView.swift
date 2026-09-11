import AppStateContainer
import SwiftUI
import hCore

public struct CrossSellingView: View {
    @AppObservedObject var store: CrossSellStore

    public init() {}

    public var body: some View {
        VStack {
            if let crossSells = store.crossSells, !crossSells.others.isEmpty {
                CrossSellStackComponent(crossSells: crossSells.others)
            }
        }
        .task {
            await store.fetchCrossSell()
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingView()
}
