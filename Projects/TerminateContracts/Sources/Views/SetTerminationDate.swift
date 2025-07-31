import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDate: View {
    @State private var terminationDate = Date()
    @State private var isHidden = false
    @ObservedObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init(
        terminationDate: () -> Date,
        terminationNavigationVm: TerminationFlowNavigationViewModel
    ) {
        self.terminationNavigationVm = terminationNavigationVm
        self._terminationDate = State(wrappedValue: terminationNavigationVm.terminationDateStepModel?.date ?? Date())
    }

    var body: some View {
        if let termination = terminationNavigationVm.terminationDateStepModel {
            DatePickerView(
                vm: .init(
                    continueAction: {
                        terminationNavigationVm.terminationDateStepModel?.date = terminationDate
                        terminationNavigationVm.isDatePickerPresented = false
                        terminationNavigationVm.fetchNotification()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isHidden = true
                        }
                    },
                    cancelAction: {
                        terminationNavigationVm.isDatePickerPresented = false
                    },
                    date: $terminationDate,
                    config: .init(
                        minDate: termination.minDate.localDateToDate,
                        maxDate: termination.maxDate.localDateToDate,
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

#Preview {
    SetTerminationDate(
        terminationDate: { Date() },
        terminationNavigationVm: .init(configs: [], terminateInsuranceViewModel: nil)
    )
}
