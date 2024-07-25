import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeCodeView: View {
    @StateObject var vm = ChangeCodeViewModel()
    @EnvironmentObject var router: Router

    var body: some View {
        TextInputView(vm: vm.inputVm)
            .task {
                vm.router = router
            }
    }
}

class ChangeCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    @Inject var foreverService: ForeverClient
    var router: Router?

    init() {
        let store: ForeverStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: store.state.foreverData?.discountCode ?? "",
            title: L10n.ReferralsEmpty.Code.headline
        )

        inputVm.onSave = { [weak self] text in
            try await self?.handleOnSave()
        }

        inputVm.onDismiss = { [weak self] in
            try await self?.dismissRouter()
        }
    }

    @MainActor
    private func dismissRouter() async throws {
        self.router?.dismiss()
    }

    @MainActor
    func handleOnSave() async throws {
        inputVm.onSave = { [weak self] text in
            try await self?.foreverService.changeCode(code: text)
            let store: ForeverStore = globalPresentableStoreContainer.get()
            store.send(.fetch)
            self?.router?.push(ForeverRouterActions.success)
        }
    }

}

struct ChangeCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeCodeView()
    }
}
