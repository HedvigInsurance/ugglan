import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SetTerminationDate: View {
    @State private var terminationDate = Date()
    let onSelected: (Date) -> Void
    //    @PresentableStore var store: ContractStore

    public init(
        onSelected: @escaping (Date) -> Void
    ) {
        self.onSelected = onSelected
    }

    //    public struct ItemPickerScreen<T>: View {
    //        var items: [(object: T, displayName: String)]
    //        let onSelected: (T) -> Void
    //        public init(
    //            items: [(object: T, displayName: String)],
    //            onSelected: @escaping (T) -> Void
    //        ) {
    //            self.items = items
    //            self.onSelected = onSelected
    //        }
    //
    //        public var body: some View {
    //            hForm {
    //                hSection {
    //                    ForEach(items, id: \.displayName) { item in
    //                        hRow {
    //                            hText(item.displayName, style: .body)
    //                                .foregroundColor(hLabelColor.primary)
    //                        }
    //                        .onTap {
    //                            onSelected(item.object)
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }

    public var body: some View {

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
                        hText(formatAndPrintDate(), style: .body)
                            .foregroundColor(hLabelColor.link)
                    }
                }

                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        state.terminations
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
                hButton.LargeButtonFilled {
                    onSelected(terminationDate)
                    //                    store.send(.submitTerminationDate(terminationDate: terminationDate))
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
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

    func formatAndPrintDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: terminationDate)
    }

    func convertDateFormat(inputDate: String) -> Date {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dateString = dateFormatter.date(from: inputDate) else {
            return Date()
        }
        return dateString
    }
}
