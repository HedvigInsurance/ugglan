import SwiftUI
import hCore
import hCoreUI

public struct DamamagePickerScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var chosenDamage: String

    public init() {
        chosenDamage = ""
    }

    public var body: some View {
        hForm {

            hSection {
                hRow {
                    hText("Front")
                }
                .onTap {
                    chosenDamage = "Front"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("Back")
                }
                .onTap {
                    chosenDamage = "Back"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("Water Damage")
                }
                .onTap {
                    chosenDamage = "Water Damage"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("Other")
                }
                .onTap {
                    chosenDamage = "Other"
                    store.send(.dissmissNewClaimFlow)
                }
            }
        }
    }
}

struct DamamagePickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        DamamagePickerScreen()
    }
}
