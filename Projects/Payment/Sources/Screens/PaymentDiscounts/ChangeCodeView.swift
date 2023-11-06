import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ChangeCodeView: View {
    @StateObject var vm = ChangeCodeViewModel()
    var body: some View {
        if vm.codeChanged {
            hForm {
                SuccessScreen(title: L10n.ReferralsChange.codeChanged)
            }
        } else {
            TextInputView(vm: vm.inputVm)
        }
    }
}

class ChangeCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    var errorMessage: String?
    @Published var codeChanged: Bool = false
    @Inject var hForeverCodeService: hForeverCodeService
    init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: store.state.paymentDiscountsData?.referralsData.code ?? "",
            title: L10n.ReferralsEmpty.Code.headline,
            dismiss: { [weak store] in
                store?.send(.navigation(to: .goBack))
            }
        )

        inputVm.onSave = { [weak self] text in
            try await self?.hForeverCodeService.chageCode(new: text)
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(.fetchDiscountsData)
            await self?.onSuccessSave()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak store] in
                store?.send(.navigation(to: .goBack))
            }
        }
    }

    @MainActor
    func onSuccessSave() async {
        withAnimation {
            codeChanged = true
        }
    }
}

extension ChangeCodeView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: ChangeCodeView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            //            if case .showChangeCodeSuccess = action {
            //                SuccessScreen.journey(with: L10n.ReferralsChange.codeChanged)
            //                    .onPresent {
            //                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //                            let store: ForeverStore = globalPresentableStoreContainer.get()
            //                            store.send(.dismissChangeCodeDetail)
            //                        }
            //                    }
            //            }
            if case let .navigation(navigateTo) = action {
                if case .goBack = navigateTo {
                    PopJourney()
                }
            }
        }
        .configureTitle(L10n.ReferralsChange.changeCode)
    }
}
struct ChangeCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeCodeView()
    }
}
