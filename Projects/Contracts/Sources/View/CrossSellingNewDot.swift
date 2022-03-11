import Foundation
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingUnseenCircle: View {
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: {
                $0.hasUnseenCrossSell
            },
            setter: { value in
                .hasSeenCrossSells(value: value)
            }
        ) { hasUnseenCrossSell, setHasSeenCrossSells in
            if hasUnseenCrossSell {
                Circle()
                    .fill(hTintColor.red)
                    .frame(width: 8, height: 8)
                    .onDisappear {
                        setHasSeenCrossSells(true)
                    }
            }
        }
    }
}
