import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct AddCampaingCodeView: View {
    @StateObject var vm = AddCampaingCodeViewModel()
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
    }
}

class AddCampaingCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    var errorMessage: String?
    @Published var codeAdded: Bool = false
    @Published var hideTitle: Bool = false

    @Inject var campaignsService: hCampaignsService
    @PresentableStore var store: PaymentStore
    init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: "",
            title: L10n.referralAddcouponInputplaceholder,
            dismiss: { [weak store] in
                store?.send(.navigation(to: .goBack))
            }
        )

        inputVm.onSave = { [weak self] text in
            try await self?.campaignsService.add(code: text)
            self?.store.send(.fetchDiscountsData)

            await self?.onSuccessAdd()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.store.send(.navigation(to: .goBack))
            }
        }
    }

    @MainActor
    func onSuccessAdd() async {
        hideTitle = true
        withAnimation(.easeInOut(duration: 0.2)) {
            codeAdded = true
        }
    }
}

extension AddCampaingCodeView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: AddCampaingCodeView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case .goBack = navigateTo {
                    PopJourney()
                }
            }
        }
    }
}

struct AddCampaingCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsServiceDemo() })
        return AddCampaingCodeView()
    }
}
