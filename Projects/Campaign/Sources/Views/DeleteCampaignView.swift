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
                                hCoreUIAssets.lock.view
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(hTextColor.Opaque.primary)

                            }
                            VStack(spacing: .padding8) {
                                hButton(
                                    .large,
                                    .primary,
                                    content: .init(title: L10n.paymentsConfirmCodeRemove),
                                    {
                                        vm.confirmRemove()
                                    }
                                )
                                .hButtonIsLoading(vm.isLoading)

                                hCancelButton {
                                    router.dismiss()
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
    @Published var codeRemoved = false
    @Published var isLoading = false
    @Published var error: String? = nil
    var router: Router?
    let onInputChange: () -> Void

    init(
        discount: Discount,
        onInputChange: @escaping () -> Void
    ) {
        self.discount = discount
        self.onInputChange = onInputChange
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
            onInputChange()
            store.send(.fetchDiscountsData)
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
                    discountPerReferral: .sek(10),
                    listOfAffectedInsurances: [],
                    validUntil: nil,
                    canBeDeleted: false,
                    discountId: "id"
                ),
                onInputChange: {}
            )
        )
    }
}
