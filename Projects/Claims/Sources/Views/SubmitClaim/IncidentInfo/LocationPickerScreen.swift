import SwiftUI
import hCore
import hCoreUI

struct LocationPickerScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var type: ClaimsNavigationAction.LocationPickerType
    init(
        type: ClaimsNavigationAction.LocationPickerType
    ) {
        self.type = type

    }

    var body: some View {
        LoadingViewWithContent(.postLocation) {
            hForm {
                hSection {
                    PresentableStoreLens(
                        SubmitClaimStore.self,
                        getter: { state in
                            state.locationStep
                        }
                    ) { locationStep in
                        if let data = locationStep?.options {
                            ForEach(data, id: \.value) { element in
                                hRow {
                                    hText(element.displayName, style: .body)
                                        .foregroundColor(hLabelColor.primary)
                                }
                                .withSelectedAccessory(locationStep?.location == element.value)
                                .onTap {
                                    let executedAction: SubmitClaimsAction = {
                                        switch type {
                                        case .setLocation:
                                            return .setNewLocation(location: element.value)
                                        case .submitLocation:
                                            return .locationRequest(location: element.value)
                                        }
                                    }()
                                    store.send(executedAction)
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
}
