import SwiftUI
import hCore
import hCoreUI

public struct LocationPickerScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        hForm {
            hSection {

                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.newClaims
                    }
                ) { claim in

                    let data = claim.listOfLocation

                    ForEach(data ?? [NewClaimsInfo(displayValue: "", value: "")], id: \.self) { element in
                        hRow {
                            hText(element.displayValue, style: .body)
                                .foregroundColor(hLabelColor.primary)
                        }
                        .onTap {
                            store.send(.submitClaimLocation(displayValue: element.displayValue, value: element.value))
                        }
                    }
                }
            }
            .withHeader {
                hText(L10n.Claims.Incident.Screen.location, style: .title1)
            }
        }
    }
}
