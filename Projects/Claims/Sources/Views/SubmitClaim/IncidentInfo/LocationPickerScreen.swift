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
                        state.locationStep
                    }
                ) { locationStep in
                    if let data = locationStep?.options {
                        Text("")
                        ForEach(data, id: \.value) { element in
                            hRow {
                                hText(element.displayName, style: .body)
                                    .foregroundColor(hLabelColor.primary)
                            }
                            .onTap {
                                store.send(.setNewLocation(location: element.value))
                            }
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
