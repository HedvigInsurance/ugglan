import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeEuroBonusView: View {
    @StateObject private var vm = ChangeEurobonusViewModel()
    var body: some View {
        TextInputView(vm: vm.inputVm)
    }
}

struct ChangeEuroBonusView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEuroBonusView()
    }
}

private class ChangeEurobonusViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    @Inject var octopus: hOctopus
    let disposeBag = DisposeBag()
    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            input: store.state.partnerData?.sas?.eurobonusNumber ?? "",
            title: L10n.ReferralsChange.changeCode,
            dismiss: { [weak store] in
                store?.send(.dismissChangeEuroBonus)
            }
        )

        inputVm.onSave = { [weak self] text in
            var error: Error?
            await withCheckedContinuation { continuation in
                let input = OctopusGraphQL.MemberUpdateEurobonusNumberInput(eurobonusNumber: text)
                let octopusRequest = self?.octopus.client
                    .perform(mutation: OctopusGraphQL.UpdateEurobonusNumberMutation(input: input))
                    .onValue { result in
                        if let graphQLError = result.memberUpdateEurobonusNumber.userError?.message,
                            !graphQLError.isEmpty
                        {
                            error = ChangeEuroBonusError.error(message: graphQLError)
                        } else if let partnerData = result.memberUpdateEurobonusNumber.member?.fragments
                            .partnerDataFragment
                        {
                            let store: ProfileStore = globalPresentableStoreContainer.get()
                            store.send(.setEurobonusNumber(partnerData: PartnerData(with: partnerData)))
                            store.send(.openSuccessChangeEuroBonus)
                        }
                        continuation.resume()
                    }
                    .onError { graphQLError in
                        error = graphQLError
                        continuation.resume()
                    }
                if let octopusRequest {
                    self?.disposeBag += octopusRequest
                }
            }
            if let error {
                throw error
            }
        }
    }

    enum ChangeEuroBonusError: LocalizedError {
        case error(message: String)

        public var errorDescription: String? {
            switch self {
            case let .error(message):
                return message
            }
        }
        var localizedDescription: String {
            switch self {
            case let .error(message):
                return message
            }
        }
    }
}

extension ChangeEuroBonusView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: ChangeEuroBonusView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .dismissChangeEuroBonus = action {
                PopJourney()
            } else if case .openSuccessChangeEuroBonus = action {
                SuccessScreen.journey(with: "EuroBonus connected")
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            let store: ProfileStore = globalPresentableStoreContainer.get()
                            store.send(.dismissChangeEuroBonus)
                        }
                    }
            }
        }
        .configureTitle("Enter your number")
    }
}
extension String {
    var toAlphaNumeric: String {
        let pattern = "[^A-Za-z0-9]+"

        return self.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
    }
}
