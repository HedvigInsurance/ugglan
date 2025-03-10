import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingUnseenCircle: View {
    @PresentableStore var store: CrossSellStore

    var body: some View {
        PresentableStoreLens(
            CrossSellStore.self,
            getter: { state in
                state.hasUnseenCrossSell
            }
        ) { hasUnseenCrossSell in
            if hasUnseenCrossSell {
                Circle()
                    .fill(hSignalColor.Red.element)
                    .frame(width: 8, height: 8)
                    .onDisappear {
                        let newCrossSales = store.state.crossSells.map { crossSell in
                            var newCrossSell = crossSell
                            newCrossSell.hasBeenSeen = true
                            return newCrossSell
                        }
                        store.send(.setCrossSells(crossSells: newCrossSales))
                    }
            }
        }
    }
}
