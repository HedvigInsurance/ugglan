import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ChangeCodeView: View {
    @StateObject var vm = ChangeCodeViewModel()
    var body: some View {
        TextInputView(vm: vm.inputVm)
    }
}

class ChangeCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    let disposeBag = DisposeBag()
    init() {
        let store: ForeverStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            input: store.state.foreverData?.discountCode ?? "",
            title: L10n.ReferralsChange.changeCode,
            dismiss: { [weak store] in
                store?.send(.dismissChangeCodeDetail)
            }
        )

        inputVm.onSave = { [weak self] text in
            var error: Error?
            await withCheckedContinuation { continuation in
                self?.disposeBag += ForeverServiceGraphQL().changeDiscountCode(text)
                    .onValue { value in
                        if let errorFromGraphQL = value.right {
                            error = errorFromGraphQL
                        } else {
                            let store: ForeverStore = globalPresentableStoreContainer.get()
                            store.send(.fetch)
                            store.send(.showChangeCodeSuccess)
                        }
                        continuation.resume()
                    }
            }
            if let error {
                throw error
            }
        }
    }
}

extension ChangeCodeView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            ForeverStore.self,
            rootView: ChangeCodeView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar]
        ) { action in
            if case .showChangeCodeSuccess = action {
                SuccessScreen.journey(with: L10n.ReferralsChange.codeChanged)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            let store: ForeverStore = globalPresentableStoreContainer.get()
                            store.send(.dismissChangeCodeDetail)
                        }
                    }
            }
        }
        .configureTitle(L10n.ReferralsChange.changeCode)
        .onAction(ForeverStore.self) { action, pres in
            if case .dismissChangeCodeDetail = action {
                pres.bag.dispose()
            }
        }
    }
}
struct ChangeCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeCodeView()
    }
}
