import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @PresentableStore var store: SubmitClaimStore

    var body: some View {
        LoadingViewWithContent(.postDateOfOccurrenceAndLocation) {
            hForm {

                hSection {
                    PresentableStoreLens(
                        SubmitClaimStore.self,
                        getter: { state in
                            state.dateOfOccurenceStep
                        }
                    ) { dateOfOccurenceStep in
                        hRow {
                            hText(L10n.Claims.Incident.Screen.Date.Of.incident)
                        }
                        .withCustomAccessory {
                            Spacer()

                            Group {
                                if let dateOfOccurrence = dateOfOccurenceStep?.dateOfOccurence {
                                    hText(dateOfOccurrence)
                                } else {
                                    Image(uiImage: hCoreUIAssets.calendar.image)
                                        .renderingMode(.template)
                                }
                            }
                            .foregroundColor(hLabelColor.secondary)
                        }
                        .onTap {
                            store.send(.navigationAction(action: .openDatePicker(type: .setDateOfOccurrence)))
                        }
                    }
                }

                hSection {
                    PresentableStoreLens(
                        SubmitClaimStore.self,
                        getter: { state in
                            state.locationStep
                        }
                    ) { locationStep in
                        hRow {
                            hText(L10n.Claims.Incident.Screen.location)
                        }
                        .withCustomAccessory {
                            Spacer()
                            Group {
                                if let location = locationStep?.getSelectedOption()?.displayName {
                                    hText(location.displayValue)
                                } else {
                                    hText(L10n.Claim.Location.choose)
                                }
                            }
                            .foregroundColor(hLabelColor.secondary)
                        }
                        .onTap {
                            store.send(.navigationAction(action: .openLocationPicker(type: .setLocation)))
                        }
                    }
                }
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.dateOfOccurrenceAndLocationRequest)
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)
            }
        }
    }
}

struct SubmitClaimOccurrencePlusLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrencePlusLocationScreen()
    }
}
