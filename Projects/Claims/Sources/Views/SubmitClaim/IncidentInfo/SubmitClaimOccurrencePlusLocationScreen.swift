import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @PresentableStore var store: SubmitClaimStore
    private let options: ClaimsNavigationAction.SubmitClaimOption

    init(
        options: ClaimsNavigationAction.SubmitClaimOption
    ) {
        self.options = options
    }

    var body: some View {
        hForm {}
            .hFormTitle(.small, .title1, options.title)
            .hDisableScroll
            .hFormAttachToBottom {
                VStack(spacing: 0) {
                    displayFieldsAndNotice
                        .disableOn(SubmitClaimStore.self, [.postDateOfOccurrenceAndLocation])
                    continueButton
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
                hSection {
                    hFloatingField(
                        value: locationStep.getSelectedOption()?.displayName ?? "",
                        placeholder: L10n.Claims.Location.Screen.title,
                        onTap: {
                            store.send(.navigationAction(action: .openLocationPicker))
                        }
                    )
                }
                .sectionContainerStyle(.transparent)
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
                hSection {
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
                }
                .sectionContainerStyle(.transparent)
                InfoCard(text: L10n.claimsDateNotSureNoticeLabel, type: .info)
                    .padding(16)
            }
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        LoadingButtonWithContent(SubmitClaimStore.self, .postDateOfOccurrenceAndLocation) {
            store.send(.dateOfOccurrenceAndLocationRequest)
        } content: {
            hText(L10n.generalContinueButton, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.leading, .trailing], 16)
    }
}

struct SubmitClaimOccurrencePlusLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrencePlusLocationScreen(options: [.date, .location])
    }
}
