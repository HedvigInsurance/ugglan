import Flow
import Form
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SetTerminationDate: View {
    @PresentableStore var store: TerminationContractStore
    @State private var terminationDate = Date()
    @State private var isHidden = false
    let onSelected: (Date) -> Void
    init(
        onSelected: @escaping (Date) -> Void
    ) {
        self.onSelected = onSelected
    }

    var body: some View {
        hForm {
            PresentableStoreLens(
                TerminationContractStore.self,
                getter: { state in
                    state.terminationDateStep
                }
            ) { termination in
                if let termination {
                    DatePickerView(
                        continueAction: {
                            self.onSelected(terminationDate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isHidden = true
                            }
                        },
                        cancelAction: {
                            store.send(.dismissTerminationFlow)
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
                            buttonText: L10n.generalContinueButton
                        )
                    )
                }
            }
        }
        .hDisableScroll
        .hide($isHidden)
    }
}

#Preview{
    SetTerminationDate(onSelected: { date in

    })
}
