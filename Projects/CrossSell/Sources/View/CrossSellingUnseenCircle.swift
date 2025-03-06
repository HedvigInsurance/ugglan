import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingUnseenCircle: View {
    var body: some View {
        EmptyView()
        //        PresentableStoreLens(
        //            ContractStore.self,
        //            getter: {
        //                $0.hasUnseenCrossSell
        //            },
        //            setter: { value in
        //                .hasSeenCrossSells(value: value)
        //            }
        //        ) { hasUnseenCrossSell, setHasSeenCrossSells in
        //            if hasUnseenCrossSell {
        //                Circle()
        //                    .fill(hSignalColor.Red.element)
        //                    .frame(width: 8, height: 8)
        //                    .onDisappear {
        //                        setHasSeenCrossSells(true)
        //                    }
        //            }
        //        }
    }
}
