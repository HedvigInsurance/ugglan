import SwiftUI
import hCore
import hCoreUI

public struct LocationPickerScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var type: ClaimsNavigationAction.LocationPickerType
    @State var executedAction: ClaimsAction = .navigationAction(action: .openLocationPicker(type: .submitLocation))
    public init(
        type: ClaimsNavigationAction.LocationPickerType
    ) {
        self.type = type

    }

    public var body: some View {
        LoadingViewWithContent(executedAction) {
            hForm {
                hSection {
                    PresentableStoreLens(
                        ClaimsStore.self,
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
                                    let executedAction: ClaimsAction = {
                                        switch type {
                                        case .setLocation:
                                            return .setNewLocation(location: element.value)
                                        case .submitLocation:
                                            return .claimNextLocation(location: element.value)
                                        }
                                    }()
                                    self.executedAction = executedAction
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
