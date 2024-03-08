import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeCodeView: View {
    @StateObject var vm = ChangeCodeViewModel()
    var body: some View {
        TextInputView(vm: vm.inputVm)
    }
}

class ChangeCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    let disposeBag = DisposeBag()
    var errorMessage: String?
    @Inject var foreverService: ForeverService

    init() {
        let store: ForeverStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: store.state.foreverData?.discountCode ?? "",
            title: L10n.ReferralsEmpty.Code.headline,
            dismiss: { [weak store] in
                store?.send(.dismissChangeCodeDetail)
            }
        )

        inputVm.onSave = { [weak self] text in
            try await self?.foreverService.changeCode(code: text)
            let store: ForeverStore = globalPresentableStoreContainer.get()
            store.send(.fetch)
            store.send(.showChangeCodeSuccess)
        }
    }
}

extension ChangeCodeView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            ForeverStore.self,
            rootView: ChangeCodeView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .showChangeCodeSuccess = action {
                SuccessScreen.journey(with: L10n.ReferralsChange.codeChanged)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let store: ForeverStore = globalPresentableStoreContainer.get()
                            store.send(.dismissChangeCodeDetail)
                        }
                    }
            }
        }
        .configureTitle(L10n.ReferralsChange.changeCode)
        .onAction(ForeverStore.self) { action, pres in
            if case .dismissChangeCodeDetail = action {
                pres.bag.dispose()
            }
        }
    }
}
struct ChangeCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeCodeView()
    }
}
