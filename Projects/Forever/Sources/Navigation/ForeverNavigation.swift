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
extension ForeverRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .success:
            return .init(describing: SuccessScreen.self)
        }
    }

}

public struct ForeverNavigation: View {
    @EnvironmentObject var router: Router
    @StateObject var foreverNavigationVm = ForeverNavigationViewModel()
    let useOwnNavigation: Bool

    public init(useOwnNavigation: Bool) {
        self.useOwnNavigation = useOwnNavigation
    }

    public var body: some View {
        Group {
            if useOwnNavigation {
                RouterHost(router: router) {
                    ForeverView()
                        .configureTitle(L10n.ReferralsInfoSheet.headline)
                }
            } else {
                ForeverView()
                    .configureTitle(L10n.ReferralsInfoSheet.headline)
            }
        }
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
                .configureTitle(L10n.ReferralsChange.changeCode)
                .embededInNavigation(options: [.navigationType(type: .large)])
        }
        .environmentObject(foreverNavigationVm)

    }
}

#Preview{
    ForeverNavigation(useOwnNavigation: true)
}

extension View {
    @ViewBuilder
    public func hideToolbar() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbar(.hidden, for: .tabBar)
        } else {
            self
        }
    }
}
