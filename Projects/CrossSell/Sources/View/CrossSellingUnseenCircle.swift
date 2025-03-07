import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingUnseenCircle: View {
    @ObservedObject var vm: CrossSellingViewModel

    var body: some View {
        if vm.hasUnseenCrossSell {
            Circle()
                .fill(hSignalColor.Red.element)
                .frame(width: 8, height: 8)
                .onDisappear {
                    vm.crossSells = vm.crossSells.map { crossSell in
                        var newCrossSell = crossSell
                        newCrossSell.hasBeenSeen = true
                        return newCrossSell
                    }
                }
        }
    }
}
