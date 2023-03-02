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
                }
                .onTap {
                    chosenLocation = "Hemma"
                    store.send(.dismissLocation)
                }
                hRow {
                    hText("I Sverige")
                }
                .onTap {
                    chosenLocation = "I Sverige"
                    store.send(.dismissLocation)
                }
                hRow {
                    hText("Utomlands")
                }
                .onTap {
                    chosenLocation = "Utomlands"
                    store.send(.dismissLocation)
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
