import Flow
import Form
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SetTerminationDate: View {
    @State private var terminationDate = Date()
    let onSelected: (Date) -> Void

    public init(
        onSelected: @escaping (Date) -> Void
    ) {
        self.onSelected = onSelected
    }

    public var body: some View {

        LoadingViewWithContent(ContractStore.self, [.sendTerminationDate]) {
            hForm {
                HStack(spacing: 0) {
                    hText(L10n.setTerminationDateText, style: .body)
                        .padding([.leading, .trailing], 12)
                        .padding([.top, .bottom], 16)
                }
                .background(hBackgroundColor.tertiary)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], 16)
                .padding(.top, 20)

                hSection {
                    hRow {
                        HStack {
                            hText(L10n.terminationDateText, style: .body)
                            Spacer()
                            hText(terminationDate.displayDateDotFormat ?? "", style: .body)
                                .foregroundColor(hLabelColor.link)
                        }
                    }

                    PresentableStoreLens(
                        ContractStore.self,
                        getter: { state in
                            state.terminationDateStep
                        }
                    ) { termination in

                        DatePicker(
                            L10n.terminationDateText,
                            selection: self.$terminationDate,
                            in: convertDateFormat(
                                inputDate: termination?.minDate ?? ""
                            )...convertDateFormat(inputDate: termination?.maxDate ?? ""),
                            displayedComponents: [.date]
                        )
                        .environment(\.locale, Locale.init(identifier: Localization.Locale.currentLocale.rawValue))
                        .datePickerStyle(.graphical)
                        .padding([.leading, .trailing], 16)
                        .padding(.top, 5)
                    }
                }
            }
            .hFormAttachToBottom {

                VStack {
                    hButton.LargeButtonPrimary {
                        onSelected(terminationDate)
                    } content: {
                        hText(L10n.terminationConfirmButton, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)
                            .frame(minHeight: 52)
                            .frame(minWidth: 200)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding([.top, .leading, .trailing], 16)
                .padding(.bottom, 40)
            }
        }
    }

    func convertDateFormat(inputDate: String) -> Date {
        return inputDate.localDateToDate ?? Date()
    }
}
