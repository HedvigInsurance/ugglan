import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    private let options: SubmitClaimsNavigationAction.SubmitClaimOption
    private let model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels

    init(
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) {
        self.model = model

        if model.dateOfOccurencePlusLocationModel != nil {
            options = [.date, .location]
        } else if model.dateOfOccurenceModel != nil {
            options = [.date]
        } else if model.locationModel != nil {
            options = [.location]
        } else {
            options = []
        }
    }

    var body: some View {
        hForm {}
            .hFormTitle(title: .init(.small, .displayXSLong, options.title))
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
            .claimErrorTrackerFor([.postDateOfOccurrenceAndLocation])
    }

    @ViewBuilder
    private var displayFieldsAndNotice: some View {

        //        PresentableStoreLens(
        //            SubmitClaimStore.self,
        //            getter: { state in
        //                state.locationStep
        //            }
        //        ) { locationStep in
        if let locationStep = model.locationModel {

            //            if let locationStep = locationStep {
            hFloatingField(
                value: locationStep.getSelectedOption()?.displayName ?? "",
                placeholder: L10n.Claims.Location.Screen.title,
                onTap: {
                    claimsNavigationVm.isLocationPickerPresented = true
                }
            )
            .padding(.bottom, .padding4)
        }
        //        }

        //        PresentableStoreLens(
        //            SubmitClaimStore.self,
        //            getter: { state in
        //                state.dateOfOccurenceStep
        //            }
        //        ) { dateOfOccurenceStep in
        //            if let dateOfOccurrenceStep = dateOfOccurenceStep {
        if let dateOfOccurrenceStep = model.dateOfOccurenceModel {
            hDatePickerField(
                config: .init(
                    maxDate: dateOfOccurrenceStep.getMaxDate(),
                    placeholder: L10n.Claims.Item.Screen.Date.Of.Incident.button,
                    title: L10n.Claims.Incident.Screen.Date.Of.incident
                ),
                selectedDate: dateOfOccurrenceStep.dateOfOccurence?.localDateToDate,
                placehodlerText: L10n.Claims.Item.Screen.Date.Of.Incident.button
            ) { date in
                store.send(.setNewDate(dateOfOccurrence: date.localDateString))
            }
            InfoCard(text: L10n.claimsDateNotSureNoticeLabel, type: .info)
                .padding(.vertical, .padding16)
        }
        //        }
    }

    @ViewBuilder
    private var continueButton: some View {
        hButton.LargeButton(type: .primary) {
            store.send(.dateOfOccurrenceAndLocationRequest)
        } content: {
            hText(L10n.generalContinueButton, style: .body1)
        }
        .trackLoading(SubmitClaimStore.self, action: .postDateOfOccurrenceAndLocation)
        .presentableStoreLensAnimation(.default)
    }
}

struct SubmitClaimOccurrencePlusLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrencePlusLocationScreen(
            model: .init(dateOfOccurencePlusLocationModel: nil, dateOfOccurenceModel: nil, locationModel: nil)
        )
    }
}
