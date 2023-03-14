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
                    hText(L10n.Claims.Item.Problem.Broken.front, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenDamage = L10n.Claims.Item.Problem.Broken.front
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText(L10n.Claims.Item.Problem.Broken.back, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenDamage = L10n.Claims.Item.Problem.Broken.back
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText(L10n.Claims.Item.Problem.Water.damage, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenDamage = L10n.Claims.Item.Problem.Water.damage
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText(L10n.Claims.Item.Problem.Broken.other, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenDamage = L10n.Claims.Item.Problem.Broken.other
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
