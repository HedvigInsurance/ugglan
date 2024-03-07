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
    @Inject var profileService: ProfileService
    let disposeBag = DisposeBag()
    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .euroBonus),
            input: store.state.partnerData?.sas?.eurobonusNumber ?? "",
            title: L10n.SasIntegration.title,
            dismiss: { [weak store] in
                store?.send(.dismissChangeEuroBonus)
            }
        )

        inputVm.onSave = { [weak self] text in
            let text = text.toAlphaNumeric
            guard !text.isEmpty else { throw ChangeEuroBonusError.error(message: L10n.SasIntegration.incorrectNumber) }
            guard Masking(type: .euroBonus).isValid(text: text) else {
                throw ChangeEuroBonusError.error(message: L10n.SasIntegration.incorrectNumber)
            }
            let data = try await self?.profileService.update(eurobonus: text)
            let store: ProfileStore = globalPresentableStoreContainer.get()
            store.send(.setEurobonusNumber(partnerData: data))
            store.send(.openSuccessChangeEuroBonus)
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
            if case .openSuccessChangeEuroBonus = action {
                SuccessScreen.journey(with: L10n.SasIntegration.eurobonusConnected)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let store: ProfileStore = globalPresentableStoreContainer.get()
                            store.send(.dismissChangeEuroBonus)
                        }
                    }
            }
        }
        .configureTitle(L10n.SasIntegration.enterYourNumber)
        .onAction(ProfileStore.self) { action in
            if case .dismissChangeEuroBonus = action {
                PopJourney()
            }
        }
    }
}
extension String {
    var toAlphaNumeric: String {
        let pattern = "[^A-Za-z0-9]+"

        return self.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
    }
}
