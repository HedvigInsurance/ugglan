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
            hSection {
                hRow {
                    hText(L10n.Claims.Location.At.home, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenLocation = L10n.Claims.Location.At.home
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText(L10n.Claims.Location.In.Home.country, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenLocation = L10n.Claims.Location.In.Home.country
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText(L10n.Claim.Location.abroad, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .onTap {
                    chosenLocation = L10n.Claim.Location.abroad
                    store.send(.dissmissNewClaimFlow)
                }
            }
            .withHeader {
                hText(L10n.Claims.Incident.Screen.location, style: .title1)
            }
        }
    }
}

struct LocationPickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationPickerScreen()
    }
}
