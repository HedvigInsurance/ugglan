import SwiftUI
import hCore
import hCoreUI

struct SumitClaimEmergencySelectScreen: View {
    @State var selectedValue: Bool = true
    @PresentableStore var store: SubmitClaimStore
    @State var isLoading: Bool = false
    let title: () -> String

    init(
        title: @escaping () -> String
    ) {
        self.title = title
    }
    var body: some View {
        hForm {}
            .hFormTitle(.small, .title1, title())
            .hFormAttachToBottom {
                VStack(spacing: 16) {
                    buttonView()
                    hButton.LargeButton(type: .primary) {
                        store.send(.emergencyConfirmRequest(isEmergency: selectedValue))
                    } content: {
                        hText(L10n.generalContinueButton)
                    }
                    .hButtonIsLoading(isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .hDisableScroll
            .onReceive(
                store.loadingSignal
                    .plain()
                    .publisher
            ) { value in
                withAnimation {
                    isLoading = value[.postConfirmEmergency] == .loading
                }
            }
    }

    func buttonView() -> some View {

        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.emergencyConfirm
            }
        ) { confirmEmergency in
            HStack(spacing: 8) {
                ForEach(confirmEmergency?.options ?? [], id: \.displayName) { option in
                    if option.value == selectedValue {
                        hButton.MediumButton(type: .primaryAlt) {
                            withAnimation(.spring()) {
                                selectedValue = option.value
                            }
                        } content: {
                            hText(option.displayName)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    } else {
                        hButton.MediumButton(type: .secondary) {
                            withAnimation(.spring()) {
                                selectedValue = option.value
                            }
                        } content: {
                            hText(option.displayName)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .hUseLightMode
            }
        }
    }
}

struct SumitClaimEmergencySelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        SumitClaimEmergencySelectScreen {
            return L10n.submitClaimEmergencyTitle
        }
    }
}
