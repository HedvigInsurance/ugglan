import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @ObservedObject var claimsNavigationVm: ClaimsNavigationViewModel
    @State private var options: SubmitClaimsNavigationAction.SubmitClaimOption = []
    @StateObject private var vm = SubmitClaimOccurrencePlusLocationViewModel()

    init(
        claimsNavigationVm: ClaimsNavigationViewModel
    ) {
        self.claimsNavigationVm = claimsNavigationVm

        if claimsNavigationVm.occurrencePlusLocationModel?.dateOfOccurencePlusLocationModel != nil {
            options = [.date, .location]
        } else if claimsNavigationVm.occurrencePlusLocationModel?.dateOfOccurrenceModel != nil {
            options = [.date]
        } else if claimsNavigationVm.occurrencePlusLocationModel?.locationModel != nil {
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
                        continueButton
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
    }

    @ViewBuilder
    private var displayFieldsAndNotice: some View {

        if let locationStep = claimsNavigationVm.occurrencePlusLocationModel?.locationModel {
            hFloatingField(
                value: locationStep.getSelectedOption()?.displayName ?? "",
                placeholder: L10n.Claims.Location.Screen.title,
                onTap: {
                    claimsNavigationVm.isLocationPickerPresented = true
                }
            )
            .padding(.bottom, .padding4)
        }

        if let dateOfOccurrenceStep = claimsNavigationVm.occurrencePlusLocationModel?.dateOfOccurrenceModel {
            hDatePickerField(
                config: .init(
                    maxDate: dateOfOccurrenceStep.getMaxDate(),
                    placeholder: L10n.Claims.Item.Screen.Date.Of.Incident.button,
                    title: L10n.Claims.Incident.Screen.Date.Of.incident
                ),
                selectedDate: dateOfOccurrenceStep.dateOfOccurence?.localDateToDate,
                placehodlerText: L10n.Claims.Item.Screen.Date.Of.Incident.button
            ) { date in
                claimsNavigationVm.occurrencePlusLocationModel?.dateOfOccurrenceModel?.dateOfOccurence =
                    date.localDateString
            }
            InfoCard(text: L10n.claimsDateNotSureNoticeLabel, type: .info)
                .padding(.vertical, .padding16)
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        hButton.LargeButton(type: .primary) {
            Task {
                let step = await vm.dateOfOccurrenceAndLocationRequest(
                    context: claimsNavigationVm.currentClaimContext ?? "",
                    model: claimsNavigationVm.occurrencePlusLocationModel
                )

                if let step {
                    claimsNavigationVm.navigate(data: step)
                }
            }

        } content: {
            hText(L10n.generalContinueButton, style: .body1)
        }
        .presentableStoreLensAnimation(.default)
    }
}

public class SubmitClaimOccurrencePlusLocationViewModel: ObservableObject {
    @Inject private var service: SubmitClaimClient
    @Published var viewState: ProcessingState = .loading

    @MainActor
    func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels?
    ) async -> SubmitClaimStepResponse? {
        //        setProgress(to: 0)

        withAnimation {
            self.viewState = .loading
        }

        do {
            let data = try await service.dateOfOccurrenceAndLocationRequest(context: context, model: model)

            withAnimation {
                self.viewState = .success
            }

            return data
        } catch let exception {
            withAnimation {
                self.viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
        return nil
    }
}

struct SubmitClaimOccurrencePlusLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrencePlusLocationScreen(claimsNavigationVm: .init())
    }
}
