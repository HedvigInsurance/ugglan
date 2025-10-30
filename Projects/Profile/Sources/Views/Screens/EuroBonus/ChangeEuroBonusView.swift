import PresentableStore
import SwiftUI
import hCore
import hCoreUI

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
        .task {
            vm.router = router
        }
    }
}

#Preview {
    ChangeEuroBonusView()
}

@MainActor
private class ChangeEurobonusViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    var profileService = ProfileService()
    var router: Router?

    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .euroBonus),
            input: store.state.partnerData?.sas?.eurobonusNumber ?? "",
            title: L10n.SasIntegration.title
        )

        inputVm.onSave = { [weak self] text in
            try await self?.handleOnSave(with: text)
        }
    }

    @MainActor
    private func handleOnSave(with text: String) async throws {
        let text = text.toAlphaNumeric
        guard !text.isEmpty else { throw ChangeEuroBonusError.error(message: L10n.SasIntegration.incorrectNumber) }
        guard Masking(type: .euroBonus).isValid(text: text) else {
            throw ChangeEuroBonusError.error(message: L10n.SasIntegration.incorrectNumber)
        }
        let data = try await profileService.update(eurobonus: text)
        let store: ProfileStore = globalPresentableStoreContainer.get()
        store.send(.setEurobonusNumber(partnerData: data))
        router?.push(EuroBonusRouterType.successChangeEuroBonus)
    }
}

extension String {
    var toAlphaNumeric: String {
        let pattern = "[^A-Za-z0-9]+"

        return replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
    }
}
