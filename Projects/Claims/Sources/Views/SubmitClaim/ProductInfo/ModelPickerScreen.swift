import SwiftUI
import hCore
import hCoreUI

public struct ModelPickerScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var chosenModel: String

    public init() {
        chosenModel = ""
    }

    public var body: some View {
        hForm {

            hSection {
                hRow {
                    hText("iPhone 13")
                }
                .onTap {
                    chosenModel = "iPhone 13"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("iPhone 14")
                }
                .onTap {
                    chosenModel = "iPhone 14"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("iPhone 11")
                }
                .onTap {
                    chosenModel = "iPhone 11"
                    store.send(.dissmissNewClaimFlow)
                }
                hRow {
                    hText("iPhone XR")
                }
                .onTap {
                    chosenModel = "iPhone XR"
                    store.send(.dissmissNewClaimFlow)
                }
            }
        }
    }
}

struct ModelPickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        ModelPickerScreen()
    }
}
