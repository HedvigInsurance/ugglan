import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @PresentableStore var store: SubmitClaimStore
    private let options: SubmitClaimsNavigationAction.SubmitClaimOption

    init(
        options: SubmitClaimsNavigationAction.SubmitClaimOption
    ) {
        self.options = options
    }

    var body: some View {
        hForm {}
            .hFormTitle(.small, .title1, options.title)
            .hDisableScroll
            .hFormAttachToBottom {
                VStack(spacing: 0) {
                    hSection {
                        displayFieldsAndNotice
                            .disableOn(SubmitClaimStore.self, [.postDateOfOccurrenceAndLocation])
                        continueButton
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
    }

    @ViewBuilder
    private var displayFieldsAndNotice: some View {

        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.locationStep
            }
        ) { locationStep in
            if let locationStep = locationStep {
                hFloatingField(
                    value: locationStep.getSelectedOption()?.displayName ?? "",
                    placeholder: L10n.Claims.Location.Screen.title,
                    onTap: {
                        store.send(.navigationAction(action: .openLocationPicker))
                    }
                )
                .padding(.bottom, 4)
            }
        }

        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.dateOfOccurenceStep
            }
        ) { dateOfOccurenceStep in

            if let dateOfOccurrenceStep = dateOfOccurenceStep {
                hDatePickerField(
                    config: .init(
                        maxDate: dateOfOccurenceStep?.getMaxDate(),
                        placeholder: L10n.Claims.Item.Screen.Date.Of.Incident.button,
                        title: L10n.Claims.Incident.Screen.Date.Of.incident
                    ),
                    selectedDate: dateOfOccurrenceStep.dateOfOccurence?.localDateToDate,
                    placehodlerText: L10n.Claims.Item.Screen.Date.Of.Incident.button
                ) { date in
                    store.send(.setNewDate(dateOfOccurrence: date.localDateString))
                }
                InfoCard(text: L10n.claimsDateNotSureNoticeLabel, type: .info)
                    .padding(.vertical, 16)
            }
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        LoadingButtonWithContent(SubmitClaimStore.self, .postDateOfOccurrenceAndLocation) {
            store.send(.dateOfOccurrenceAndLocationRequest)
        } content: {
            hText(L10n.generalContinueButton, style: .body)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}

struct SubmitClaimOccurrencePlusLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrencePlusLocationScreen(options: [.date, .location])
    }
}
