import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View {

    @PresentableStore var store: ClaimsStore
    @State var phoneNumber: String

    public init(
        model: FlowClaimPhoneNumberStepModel
    ) {
        self.phoneNumber = model.phoneNumber
    }
    public var body: some View {

        LoadingViewWithContent(.claimNextPhoneNumber(phoneNumber: phoneNumber)) {
            hForm {
                HStack(spacing: 0) {
                    hText(L10n.Message.Claims.Ask.phone, style: .body)
                        .foregroundColor(hLabelColor.primary)
                        .padding([.trailing, .leading], 12)
                        .padding([.top, .bottom], 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(hBackgroundColor.tertiary)
                .cornerRadius(12)
                .padding(.leading, 16)
                .padding(.trailing, 32)
                .padding(.top, 20)
                .hShadow()
            }
            .hFormAttachToBottom {
                VStack {
                    HStack {
                        VStack {
                            TextField(phoneNumber, text: $phoneNumber)
                                .font(.title2)
                                .foregroundColor(hLabelColor.primary)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .onReceive(Just(phoneNumber)) { newValue in
                                    let filteredNumbers = newValue.filter { "0123456789".contains($0) }
                                    if filteredNumbers != newValue {
                                        self.phoneNumber = filteredNumbers
                                    }
                                }
                            hText(L10n.phoneNumberRowTitle, style: .footnote)
                                .foregroundColor(hLabelColor.primary)
                        }
                        .padding([.top, .bottom], 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(hBackgroundColor.tertiary)
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 16)
                    hButton.LargeButtonFilled {
                        store.send(.claimNextPhoneNumber(phoneNumber: phoneNumber))
                        UIApplication.dismissKeyboard()
                    } content: {
                        hText(L10n.generalContinueButton, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding([.leading, .trailing], 16)
                    .padding(.bottom, 6)
                }
            }
        }
    }
}

public struct LoadingViewWithContent<Content: View>: View {
    var content: () -> Content
    @PresentableStore var store: ClaimsStore
    private let action: ClaimsAction
    public init(
        _ action: ClaimsAction,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
    }
    public var body: some View {
        ZStack {
            content()
            PresentableStoreLens(
                ClaimsStore.self,
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
