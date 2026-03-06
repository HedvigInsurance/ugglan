import SwiftUI
import hCore
import hCoreUI

struct ChangeCodeView: View {
    @ObservedObject private var vm: ChangeCodeViewModel
    @EnvironmentObject private var router: NavigationRouter

    init(
        foreverNavigationVm: ForeverNavigationViewModel
    ) {
        vm = .init(input: foreverNavigationVm.foreverData?.discountCode ?? "", foreverVm: foreverNavigationVm)
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

    var router: NavigationRouter?
    let foreverVm: ForeverNavigationViewModel?

    init(
        input: String,
        foreverVm: ForeverNavigationViewModel
    ) {
        self.foreverVm = foreverVm

        inputVm = ChangeCodeViewModel.createInputViewModel(input: input)

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
        router?.dismiss()
    }

    private func handleOnSave(text: String) async throws {
        try await foreverService.changeCode(code: text)
        try await foreverVm?.fetchForeverData()
        router?.push(ForeverRouterActions.success)
    }
}

#Preview {
    ChangeCodeView(foreverNavigationVm: .init())
        .environmentObject(NavigationRouter())
}
