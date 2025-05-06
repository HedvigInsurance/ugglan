import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct AddCampaignCodeView: View {
    @ObservedObject private var vm: AddCampaignCodeViewModel
    @ObservedObject var campaignNavigationVm: CampaignNavigationViewModel
    @EnvironmentObject var router: Router

    init(
        campaignNavigationVm: CampaignNavigationViewModel,
        vm: AddCampaignCodeViewModel
    ) {
        self.campaignNavigationVm = campaignNavigationVm
        self.vm = vm
    }

    var body: some View {
        ZStack(alignment: .center) {
            TextInputView(vm: vm.inputVm).opacity(vm.codeAdded ? 0 : 1)
            SuccessScreen(title: L10n.paymentsDiscountAdded).opacity(vm.codeAdded ? 1 : 0)
                .offset(y: -32)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                hText(vm.hideTitle ? "" : L10n.paymentsAddCampaignCode)
            }
        }
        .task {
            vm.router = router
        }
    }
}

@MainActor
class AddCampaignCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    var errorMessage: String?
    @Published var codeAdded: Bool = false
    @Published var hideTitle: Bool = false
    var router: Router?

    var campaignsService = hCampaignService()
    @PresentableStore var store: CampaignStore
    init(
        onInputChange: @escaping () -> Void
    ) {
        inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: "",
            title: L10n.referralAddcouponInputplaceholder
        )

        inputVm.onSave = { [weak self] text in
            try await self?.campaignsService.add(code: text)
            onInputChange()
            self?.store.send(.fetchDiscountsData)

            await self?.onSuccessAdd()

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.router?.dismiss()
            }
        }

        inputVm.onDismiss = {
            try await self.dismissRouter()
        }
    }

    @MainActor
    private func onSuccessAdd() async {
        hideTitle = true
        withAnimation(.easeInOut(duration: 0.2)) {
            codeAdded = true
        }
    }

    @MainActor
    private func dismissRouter() async throws {
        self.router?.dismiss()
    }
}

struct AddCampaingCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignClientDemo() })
        return AddCampaignCodeView(
            campaignNavigationVm: .init(),
            vm: .init(onInputChange: {})
        )
    }
}
