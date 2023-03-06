import SwiftUI
import hCore
import hCoreUI

public struct LocationPickerScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var chosenLocation: String

    public init() {
        chosenLocation = ""
    }

    public var body: some View {
        hForm {
            hText(L10n.Claims.Incident.Screen.location, style: .title1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)

            hSection {
                hRow {
                    hText("Hemma")
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenLocation = "Hemma"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("I Sverige")
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenLocation = "I Sverige"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("Utomlands")
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenLocation = "Utomlands"
                    store.send(.dissmissNewClaimFlow)
                }
            }
        }
    }
}

struct LocationPickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationPickerScreen()
    }
}
