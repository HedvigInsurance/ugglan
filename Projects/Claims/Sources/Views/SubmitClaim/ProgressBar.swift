import SwiftUI
import hCore
import hCoreUI

struct ProgressBar: View {
    var body: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.progress
            }
        ) { progress in

            ProgressView(value: progress)
                .tint(hLabelColorNew.primary)

        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar()
    }
}
