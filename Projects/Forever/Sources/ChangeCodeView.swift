import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeCodeView: View {
    @ObservedObject private var vm: ChangeCodeViewModel
    @EnvironmentObject private var router: Router

    init(
        foreverNavigationVm: ForeverNavigationViewModel
    ) {
        self.vm = .init(input: foreverNavigationVm.foreverData?.discountCode ?? "", foreverVm: foreverNavigationVm)
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
    let foreverVm: ForeverNavigationViewModel?

    init(
        input: String,
        foreverVm: ForeverNavigationViewModel
    ) {
        self.foreverVm = foreverVm

        self.inputVm = ChangeCodeViewModel.createInputViewModel(input: input)

        inputVm.onSave = { [weak self] text in
            try await self?.handleOnSave(text: text)
        }

        inputVm.onDismiss = { [weak self] in
            try await self?.dismissRouter()
        }
    }

    private static func createInputViewModel(input: String) -> TextInputViewModel {
        let inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: input,
            title: L10n.ReferralsEmpty.Code.headline
        )
        return inputVm
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
            .environmentObject(Router())
    }
}
