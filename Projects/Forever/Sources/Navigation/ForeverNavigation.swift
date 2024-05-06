import SwiftUI
import hCore
import hCoreUI

public class ForeverNavigationViewModel: ObservableObject {
    @Published public var isChangeCodePresented = false
}

enum ForeverRouterActions {
    case success
}

public struct ForeverNavigation: View {
    @StateObject var router = Router()
    @StateObject var foreverNavigationVm = ForeverNavigationViewModel()

    public init() {}

    public var body: some View {
        RouterHost(router: router) {
            ForeverView()
                .configureTitle(L10n.ReferralsInfoSheet.headline)
        }
        .environmentObject(foreverNavigationVm)
        .detent(
            presented: $foreverNavigationVm.isChangeCodePresented,
            style: .height
        ) {
            ChangeCodeView()
                .routerDestination(for: ForeverRouterActions.self, options: .hidesBackButton) { routerAction in
                    switch routerAction {
                    case .success:
                        SuccessScreen(title: L10n.ReferralsChange.codeChanged)
                            .onAppear { [weak router] in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    router?.dismiss()
                                }
                            }
                    }
                }
                .configureTitle(L10n.changeAddressAddBuilding)
                .embededInNavigation(options: [.navigationType(type: .large)])
        }
    }
}

#Preview{
    ForeverNavigation()
}
