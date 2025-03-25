import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct DeleteCampaignView: View {
    @ObservedObject private var vm: DeleteCampaignViewModel
    @EnvironmentObject var router: Router

    init(vm: DeleteCampaignViewModel) {
        self.vm = vm
    }

    var body: some View {
        ZStack {
            hForm {}
                .hFormContentPosition(.compact)
                .opacity(vm.codeRemoved ? 0 : 1)
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 16) {
                            hFloatingField(
                                value: vm.discount.code,
                                placeholder: L10n.referralAddcouponInputplaceholder,
                                error: $vm.error
                            ) {

                            }
                            .hFieldTrailingView {
                                Image(uiImage: hCoreUIAssets.lock.image)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(hTextColor.Opaque.primary)

                            }
                            VStack(spacing: 8) {
                                hButton.LargeButton(type: .primary) {
                                    vm.confirmRemove()
                                } content: {
                                    hText(L10n.paymentsConfirmCodeRemove)
                                }
                                .hButtonIsLoading(vm.isLoading)

                                hButton.LargeButton(type: .ghost) {
                                    router.dismiss()
                                } content: {
                                    hText(L10n.generalCancelButton)
                                }
                                .disabled(vm.isLoading)
                            }

                        }
                        .padding(.bottom, .padding16)
                    }
                }
            SuccessScreen(title: L10n.paymentsCodeRemoved).opacity(vm.codeRemoved ? 1 : 0)
                .offset(y: -32)
        }
        .sectionContainerStyle(.transparent)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if !vm.codeRemoved {
                    VStack {
                        ForEach(vm.getTitleParts, id: \.self) { element in
                            hText(element)
                        }
                    }
                }
            }
        }
        .task {
            vm.router = router
        }
    }
}

@MainActor
class DeleteCampaignViewModel: ObservableObject {
    let discount: Discount
    private var campaignService = hCampaignService()
    @PresentableStore private var store: CampaignStore
    let paymentDataDiscounts: [Discount]
    @Published var codeRemoved = false
    @Published var isLoading = false
    @Published var error: String? = nil
    var router: Router?

    init(
        discount: Discount,
        paymentDataDiscounts: [Discount]
    ) {
        self.discount = discount
        self.paymentDataDiscounts = paymentDataDiscounts
    }

    func confirmRemove() {
        Task {
            await removeCode()
        }
    }

    @MainActor
    func removeCode() async {
        withAnimation {
            isLoading = true
        }

        do {
            error = nil
            try await campaignService.remove(codeId: discount.discountId)
            //            store.send(.load)
            store.send(.fetchDiscountsData(paymentDataDiscounts: paymentDataDiscounts))
            withAnimation {
                codeRemoved = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.router?.dismiss()
            }
        } catch let ex {
            withAnimation {
                error = ex.localizedDescription
            }
        }

        withAnimation {
            isLoading = false
        }
    }

    var getTitleParts: [String] {
        return L10n.paymentsRemoveCodeTitle.components(separatedBy: .newlines)
    }

}

struct DeleteCampaignView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteCampaignView(
            vm: .init(
                discount: .init(
                    code: "CODE",
                    amount: nil,
                    title: "Title",
                    listOfAffectedInsurances: [],
                    validUntil: nil,
                    canBeDeleted: false,
                    discountId: "id"
                ),
                paymentDataDiscounts: []
            )
        )
    }
}
