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

        LoadingViewWithContent(.sendTerminationDate(terminationDate: terminationDate)) {
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
                            hText(terminationDate.localDateString ?? "", style: .body)
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
                    hButton.LargeButtonFilled {
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

public struct LoadingViewWithContent<Content: View>: View {
    var content: () -> Content
    @PresentableStore var store: ContractStore
    private let action: ContractAction
    public init(
        _ action: ContractAction,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
    }
    public var body: some View {
        ZStack {
            content()
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.loadingStates
                }
            ) { loadingStates in
                if let state = loadingStates[action] {
                    switch state {
                    case .loading:
                        HStack {
                            WordmarkActivityIndicator(.standard)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(hBackgroundColor.primary.opacity(0.7))
                        .cornerRadius(.defaultCornerRadius)
                        .edgesIgnoringSafeArea(.top)
                    case let .error(error):
                        RetryView(title: error, retryTitle: L10n.alertOk) {
                            store.send(.setLoadingState(action: action, state: nil))
                        }
                    }

                }
            }
            .presentableStoreLensAnimation(.easeInOut)
        }
    }
}
