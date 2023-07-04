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
                            hText(terminationDate.localDateString, style: .body)
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

    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    private let withRetry: Bool
    var disposeBag = DisposeBag()

    public init(
        _ action: ContractAction,
        withRetry: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.withRetry = withRetry
        self.action = action
        self.content = content
    }
    public var body: some View {
        ZStack {
            content()
                .alert(isPresented: $presentError) {
                    if withRetry {
                        return Alert(
                            title: Text(L10n.somethingWentWrong),
                            message: Text(error),
                            primaryButton: .default(Text(L10n.alertOk)),
                            secondaryButton: .default(
                                Text(L10n.generalRetry),
                                action: { self.store.send(action) }
                            )
                        )
                    } else {
                        return Alert(
                            title: Text(L10n.somethingWentWrong),
                            message: Text(error),
                            dismissButton: .default(Text(L10n.alertOk))
                        )
                    }
                }
            if isLoading {
                HStack {
                    WordmarkActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity)
                .cornerRadius(.defaultCornerRadius)
                .edgesIgnoringSafeArea(.top)
            }
        }
        .onAppear {
            func handle(state: ContractState) {
                if let actionState = state.loadingStates[action] {
                    switch actionState {
                    case .loading:
                        withAnimation {
                            self.isLoading = true
                            self.presentError = false
                        }
                    case let .error(error):
                        withAnimation {
                            self.isLoading = false
                            self.error = error
                            self.presentError = true
                        }
                    }
                } else {
                    withAnimation {
                        self.isLoading = false
                        self.presentError = false
                    }
                }
            }
            disposeBag += store.stateSignal.onValue { state in
                handle(state: state)
            }
            handle(state: store.state)

        }
    }
}
