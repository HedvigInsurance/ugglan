import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class ForeverNavigationViewModel: ObservableObject {
    @Published public var isChangeCodePresented = false

    func shareCode(code: String) {
        let store: ForeverStore = globalPresentableStoreContainer.get()
        let discount = store.state.foreverData?.monthlyDiscountPerReferral.formattedAmount
        let url =
            "\(hGraphQL.Environment.current.webBaseURL)/\(hCore.Localization.Locale.currentLocale.webPath)/forever/\(code)"
        let message = L10n.referralSmsMessage(discount ?? "", url)

        let activityVC = UIActivityViewController(
            activityItems: [message as Any],
            applicationActivities: nil
        )

        let topViewController = UIApplication.shared.getTopViewController()
        topViewController?.present(activityVC, animated: true, completion: nil)
    }
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
