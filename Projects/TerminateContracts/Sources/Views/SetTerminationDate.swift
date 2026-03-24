import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDate: View {
    @State private var terminationDate = Date()
    @State private var isHidden = false
    @ObservedObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init(
        terminationNavigationVm: TerminationFlowNavigationViewModel
    ) {
        self.terminationNavigationVm = terminationNavigationVm
        _terminationDate = State(wrappedValue: terminationNavigationVm.selectedDate ?? Date())
    }

    var body: some View {
        if case let .terminateWithDate(minDate, maxDate, _) = terminationNavigationVm.surveyData?.action {
            DatePickerView(
                vm: .init(
                    continueAction: {
                        terminationNavigationVm.selectedDate = terminationDate
                        terminationNavigationVm.isDatePickerPresented = false
                        terminationNavigationVm.fetchNotification(for: terminationDate)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isHidden = true
                        }
                    },
                    cancelAction: {
                        terminationNavigationVm.isDatePickerPresented = false
                    },
                    date: $terminationDate,
                    config: .init(
                        minDate: minDate.localDateToDate,
                        maxDate: maxDate.localDateToDate,
                        initialySelectedValue: Date(),
                        placeholder: "",
                        title: L10n.terminationDateText,
                        showAsList: false,
                        dateFormatter: .none,
                        buttonText: L10n.generalSaveButton
                    )
                )
            )
            .hide($isHidden)
        }
    }
}

#Preview{
    SetTerminationDate(
        terminationNavigationVm: .init(configs: [], terminateInsuranceViewModel: nil)
    )
}
