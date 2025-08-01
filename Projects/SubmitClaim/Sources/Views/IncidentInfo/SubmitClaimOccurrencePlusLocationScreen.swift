import hCore
import hCoreUI
import SwiftUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @State private var options: SubmitClaimOption
    @StateObject private var vm = SubmitClaimOccurrencePlusLocationViewModel()

    init(
        claimsNavigationVm: SubmitClaimNavigationViewModel
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
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    options.title,
                    alignment: .leading
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: 0) {
                    hSection {
                        displayFieldsAndNotice
                        continueButton
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
            .claimErrorTrackerForState($vm.viewState)
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
                .accessibilitySortPriority(2)
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        hContinueButton {
            Task {
                if let model = claimsNavigationVm.occurrencePlusLocationModel {
                    let step = await vm.dateOfOccurrenceAndLocationRequest(
                        context: claimsNavigationVm.currentClaimContext ?? "",
                        model: model
                    )

                    if let step {
                        claimsNavigationVm.navigate(data: step)
                    }
                }
            }
        }
        .hButtonIsLoading(vm.viewState == .loading)
        .disabled(vm.viewState == .loading)
    }
}

@MainActor
public class SubmitClaimOccurrencePlusLocationViewModel: ObservableObject {
    private let service = SubmitClaimService()
    @Published var viewState: ProcessingState = .success

    @MainActor
    func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) async -> SubmitClaimStepResponse? {
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
