import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeCodeView: View {
    @ObservedObject private var vm: ChangeCodeViewModel
    @EnvironmentObject private var router: Router
    @ObservedObject private var foreverNavigationVm: ForeverNavigationViewModel

    init(
        foreverNavigationVm: ForeverNavigationViewModel
    ) {
        self.foreverNavigationVm = foreverNavigationVm

        let inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: foreverNavigationVm.foreverData?.discountCode ?? "",
            title: L10n.ReferralsEmpty.Code.headline
        )

        self.vm = .init(inputVm: inputVm, foreverVm: foreverNavigationVm)
    }

    var body: some View {
        TextInputView(vm: vm.inputVm)
            .task {
                vm.router = router
            }
    }
}

@MainActor
class ChangeCodeViewModel: ObservableObject {
    @Inject var foreverService: ForeverClient
    @Published var inputVm: TextInputViewModel

    var router: Router?
    weak var foreverVm: ForeverNavigationViewModel?

    init(
        inputVm: TextInputViewModel,
        foreverVm: ForeverNavigationViewModel
    ) {
        self.inputVm = inputVm
        self.foreverVm = foreverVm

        inputVm.onSave = { [weak self] text in
            try await self?.handleOnSave(text: text)
        }

        inputVm.onDismiss = { [weak self] in
            try await self?.dismissRouter()
        }
    }

    private func dismissRouter() async throws {
        self.router?.dismiss()
    }

    private func handleOnSave(text: String) async throws {
        try await self.foreverService.changeCode(code: text)
        try await foreverVm?.fetchForeverData()
        self.router?.push(ForeverRouterActions.success)
    }
}

struct ChangeCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeCodeView(foreverNavigationVm: .init())
    }
}
