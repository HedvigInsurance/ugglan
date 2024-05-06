import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeEuroBonusView: View {
    @StateObject private var vm = ChangeEurobonusViewModel()
    @EnvironmentObject var router: Router

    var body: some View {
        TextInputView(
            vm: vm.inputVm,
            dismissAction: {
                router.dismiss()
            }
        )
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
            title: L10n.SasIntegration.title
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

            /* TODO: SOMEHOW SET SUCESS HERE*/
            //  router.push(EuroBonusRouterType.successChangeEuroBonus)
        }
    }
}

extension String {
    var toAlphaNumeric: String {
        let pattern = "[^A-Za-z0-9]+"

        return self.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
    }
}
