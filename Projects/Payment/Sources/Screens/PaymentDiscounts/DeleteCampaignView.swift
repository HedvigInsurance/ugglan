import Presentation
import SwiftUI
import hCore
import hCoreUI

struct DeleteCampaignView: View {
    @ObservedObject private var vm: DeleteCampaignViewModel

    init(vm: DeleteCampaignViewModel) {
        self.vm = vm
    }

    var body: some View {
        ZStack {
            hForm {
                hSection {
                    hFloatingField(value: vm.code, placeholder: L10n.referralAddcouponInputplaceholder) {

                    }
                    .hFieldTrailingView {
                        Image(uiImage: hCoreUIAssets.lockSmall.image)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(hTextColor.primary)

                    }
                }
            }
            .opacity(vm.codeRemoved ? 0 : 1)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 16) {
                        hButton.LargeButton(type: .primary) {
                            vm.confirmRemove()
                        } content: {
                            hText(L10n.paymentsConfirmCodeRemove)
                        }
                        .hButtonIsLoading(vm.isLoading)

                        hButton.LargeButton(type: .ghost) {
                            vm.cancel()
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                        .disabled(vm.isLoading)

                    }
                    .padding(.vertical, 16)
                }
            }
            SuccessScreen(title: L10n.paymentsCodeRemoved).opacity(vm.codeRemoved ? 1 : 0)
                .offset(y: -32)
        }
        .hDisableScroll
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
    }
}

class DeleteCampaignViewModel: ObservableObject {
    let code: String
    @Inject private var campaignsService: hCampaignsService
    @PresentableStore private var store: PaymentStore
    @Published var codeRemoved = false
    @Published var isLoading = false
    @Published var error: String? = nil

    init(code: String) {
        self.code = code
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
            try await campaignsService.remove(code: code)
            store.send(.load)
            store.send(.fetchDiscountsData)
            withAnimation {
                codeRemoved = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.store.send(.navigation(to: .goBack))
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

    func cancel() {
        store.send(.navigation(to: .goBack))
    }

    var getTitleParts: [String] {
        return L10n.paymentsRemoveCodeTitle.components(separatedBy: .newlines)
    }

}

struct DeleteCampaignView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteCampaignView(vm: .init(code: "CODE"))
    }
}

extension DeleteCampaignView {
    static func journeyWith(code: String) -> some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: DeleteCampaignView(vm: .init(code: code)),
            style: .detented(.scrollViewContentSize),
            options: .largeNavigationBar
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case .goBack = navigateTo {
                    PopJourney()
                }
            }
        }
    }
}
