import SwiftUI
import hCore
import hCoreUI

struct LocationPickerScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var type: ClaimsNavigationAction.LocationPickerType
    @State var selectedLocation: String = ""

    init(
        type: ClaimsNavigationAction.LocationPickerType
    ) {
        self.type = type

    }

    var body: some View {
        LoadingViewWithContent(.postLocation) {
            hForm {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.locationStep
                    }
                ) { locationStep in
                    if let data = locationStep?.options {
                        ForEach(data, id: \.value) { element in
                            hSection {
                                hRow {
                                    hTextNew(element.displayName, style: .title3)
                                        .foregroundColor(hLabelColorNew.primary)
                                    Spacer()
                                    Circle()
                                        .strokeBorder(hBackgroundColorNew.semanticBorderTwo)
                                        .background(Circle().foregroundColor(retColor(text: element.value)))
                                        .frame(width: 28, height: 28)
                                }
                                .withEmptyAccessory
                                .onTap {
                                    if !(selectedLocation == element.value) {
                                        selectedLocation = element.value
                                    }
                                }
                            }
                            .sectionContainerStyle(.transparent)
                        }
                    }
                }
            }
            .hUseNewStyle
            .hFormAttachToBottom {
                VStack(spacing: 0) {
                    hButton.LargeButtonFilled {
                        let executedAction: SubmitClaimsAction = {
                            switch type {
                            case .setLocation:
                                return .setNewLocation(location: selectedLocation)
                            case .submitLocation:
                                return .locationRequest(location: selectedLocation)
                            }
                        }()
                        store.send(executedAction)
                    } content: {
                        hTextNew(L10n.generalSaveButton, style: .body)
                    }

                    hButton.LargeButtonText {
                        store.send(.navigationAction(action: .dismissPickerScreen))
                    } content: {
                        hTextNew(L10n.generalCancelButton, style: .body)
                    }
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    @hColorBuilder
    func retColor(text: String) -> some hColor {
        if selectedLocation == text {
            hLabelColorNew.primary
        } else {
            hBackgroundColorNew.opaqueOne
        }
    }

}
