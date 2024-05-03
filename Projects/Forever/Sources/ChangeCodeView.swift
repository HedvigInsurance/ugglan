import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeCodeView: View {
    @StateObject var vm = ChangeCodeViewModel()
    var body: some View {
        TextInputView(vm: vm.inputVm)
    }
}

class ChangeCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    let disposeBag = DisposeBag()
    var errorMessage: String?
    @Inject var foreverService: ForeverService

    init() {
        let store: ForeverStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: store.state.foreverData?.discountCode ?? "",
            title: L10n.ReferralsEmpty.Code.headline,
            dismiss: { [weak store] in
                store?.send(.dismissChangeCodeDetail)
            }
        )

        inputVm.onSave = { [weak self] text in
            try await self?.foreverService.changeCode(code: text)
            let store: ForeverStore = globalPresentableStoreContainer.get()
            store.send(.fetch)
            store.send(.showChangeCodeSuccess)
        }
    }
}

struct ChangeCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeCodeView()
    }
}
