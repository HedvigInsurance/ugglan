import Flow
import Form
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SetTerminationDate: View {
    @PresentableStore var store: TerminationContractStore
    @State private var terminationDate = Date()
    let onSelected: (Date) -> Void

    init(
        onSelected: @escaping (Date) -> Void
    ) {
        self.onSelected = onSelected
    }

    var body: some View {
        LoadingViewWithContent(TerminationContractStore.self, [.sendTerminationDate], [.sendTerminationDate]) {
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
                                return ReferenceAction(execute: {
                                    self.onSelected(terminationDate)
                                })
                            }(),
                            cancelAction: {
                                return ReferenceAction(execute: {
                                    store.send(.dismissTerminationFlow)
                                })
                            }(),
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
        }
    }
}

#Preview{
    SetTerminationDate(onSelected: { date in

    })
}
