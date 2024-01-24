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
    @Inject var octopus: hOctopus

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
            var errorMessage: String?
            await withCheckedContinuation { continuation in
                let octopusRequest = self?.octopus.client
                    .perform(mutation: OctopusGraphQL.MemberReferralInformationCodeUpdateMutation(code: text))
                    .onValue { value in
                        if let errorFromGraphQL = value.memberReferralInformationCodeUpdate.userError?.message {
                            errorMessage = errorFromGraphQL
                        } else {
                            let store: ForeverStore = globalPresentableStoreContainer.get()
                            store.send(.fetch)
                            store.send(.showChangeCodeSuccess)
                        }
                        continuation.resume()
                    }
                    .onError { graphQLError in
                        errorMessage = graphQLError.localizedDescription
                        continuation.resume()
                    }
                if let octopusRequest {
                    self?.disposeBag += octopusRequest
                }
            }
            if let errorMessage {
                throw ForeverChangeCodeError.errorMessage(message: errorMessage)
            }
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
                SuccessScreen<EmptyView>.journey(with: L10n.ReferralsChange.codeChanged)
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
