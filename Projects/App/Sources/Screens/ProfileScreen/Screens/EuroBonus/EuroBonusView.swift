import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct EuroBonusView: View {
    @StateObject var vm = EuroBonusViewModel()
    var body: some View {
        ZStack {
            form
                .toolbar {
                    toolbars
                }
                .introspectViewController(customize: { vc in
                    if vm.vc != vc {
                        vm.vc = vc
                    }
                })
                .onChange(of: vm.number) { newValue in
                    withAnimation {
                        if vm.errorMessage != nil {
                            vm.errorMessage = nil
                        }
                        vm.inEditMode = newValue != vm.previousValue
                    }
                }
                .onChange(of: vm.previousValue) { newValue in
                    withAnimation {
                        vm.inEditMode = newValue != vm.number
                    }
                }
                .navigationBarBackButtonHidden(vm.inEditMode)
                .transition(.opacity.animation(.easeInOut(duration: 2)))
            if vm.state == .loading {
                HStack {
                    WordmarkActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(hBackgroundColor.primary.opacity(0.7))
                .cornerRadius(.defaultCornerRadius)
                .edgesIgnoringSafeArea(.top)
            }
        }
        .navigationTitle(L10n.SasIntegration.title)
        .alert(isPresented: $vm.showCancelAlert) {
            cancelAlert
        }
        .slideUpFadeAppearAnimation()
    }

    @ToolbarContentBuilder
    private var toolbars: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(L10n.myInfoCancelButton) {
                vm.showCancelAlert = true
            }
            .foregroundColor(hLabelColor.primary)
            .opacity(vm.inEditMode ? 1 : 0)
            .disabled(!vm.inEditMode)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            if vm.state == .loading {
                ProgressView().foregroundColor(hLabelColor.link)

            } else {
                Button(L10n.myInfoSaveButton) {
                    UIApplication.dismissKeyboard()
                    vm.submit()
                }
                .foregroundColor(hLabelColor.link)
                .opacity(vm.inEditMode ? 1 : 0)
                .animation(.easeInOut(duration: 0.2))
                .disabled(!vm.inEditMode)
            }
        }
    }

    @ViewBuilder
    private var form: some View {
        hForm {
            hRow { hText(L10n.SasIntegration.connectYourEurobonus, style: .title3) }
            hRow {
                hText(L10n.SasIntegration.number)
                    .foregroundColor(hLabelColor.primary)
            }
            .withCustomAccessory {
                hTextField(
                    masking: Masking(type: .euroBonus),
                    value: $vm.number,
                    placeholder: L10n.SasIntegration.numberPlaceholder
                )
                .foregroundColor(hLabelColor.primary)
                .multilineTextAlignment(.trailing)
                .hTextFieldOptions([.minimumHeight(height: 40)])
            }
            .verticalPadding(1)
            hRow {
                VStack(alignment: .leading) {
                    Divider()
                    if let errorMessage = vm.errorMessage {
                        hText(errorMessage, style: .footnote).foregroundColor(hTintColor.red)
                            .transition(.opacity.animation(.default))
                    }
                }
            }
            .verticalPadding(1)
            hRow {
                hText(L10n.SasIntegration.info, style: .callout)
                    .foregroundColor(hLabelColor.secondary)
            }
            .verticalPadding(10)
        }
    }
    private var cancelAlert: SwiftUI.Alert {
        return Alert(
            title: Text(L10n.myInfoCancelAlertTitle),
            message: Text(L10n.myInfoCancelAlertMessage),
            primaryButton: .default(Text(L10n.myInfoCancelAlertButtonCancel)),
            secondaryButton: .destructive(Text(L10n.myInfoCancelAlertButtonConfirm)) {
                vm.vc?.navigationController?.popViewController(animated: true)
            }
        )
    }
}

struct EuroBonusView_Previews: PreviewProvider {
    static var previews: some View {
        EuroBonusView()
    }
}

class EuroBonusViewModel: ObservableObject {
    @Published var number: String
    @Published var previousValue: String
    @Published var inEditMode = false
    @Published var showCancelAlert = false
    weak var vc: UIViewController?
    @Published var errorMessage: String?
    @Published var state: LoadingState<String>?
    let disposeBag = DisposeBag()

    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        self.number = store.state.partnerData?.sas?.eurobonusNumber ?? ""
        self.previousValue = store.state.partnerData?.sas?.eurobonusNumber ?? ""
    }

    func submit() {
        if number.count == 0 {
            errorMessage = L10n.SasIntegration.incorrectNumber
            return
        }
        errorMessage = nil
        disposeBag.dispose()
        let store: ProfileStore = globalPresentableStoreContainer.get()
        disposeBag += store.stateSignal.onValue({ [weak self] state in
            if self?.state != state.updateEurobonusState {
                self?.state = state.updateEurobonusState
                if self?.state == nil {
                    self?.previousValue = self?.number ?? ""
                }
                if case let .error(message) = self?.state {
                    self?.errorMessage = message
                }
            }
        })
        store.send(.updateEurobonusNumber(number: number.toAlphaNumeric.uppercased()))
    }
}

extension String {
    var toAlphaNumeric: String {
        let pattern = "[^A-Za-z0-9]+"

        return self.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
    }
}
