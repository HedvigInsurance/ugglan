import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

@MainActor
public class ForeverNavigationViewModel: ObservableObject {
    @Published public var isChangeCodePresented = false
    var modalPresentationSourceWrapperViewModel = ModalPresentationSourceWrapperViewModel()

    func shareCode(code: String) {
        let store: ForeverStore = globalPresentableStoreContainer.get()
        let discount = store.state.foreverData?.monthlyDiscountPerReferral.formattedAmount
        let url =
            "\(hGraphQL.Environment.current.webBaseURL)/\(hCore.Localization.Locale.currentLocale.value.webPath)/forever/\(code)"
        let message = L10n.referralSmsMessage(discount ?? "", url)

        let activityVC = UIActivityViewController(
            activityItems: [message as Any],
            applicationActivities: nil
        )
        modalPresentationSourceWrapperViewModel.present(activity: activityVC)
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
                RouterHost(router: router, tracking: ForeverNavigationDetentType.forever) {
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
            style: [.height]
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
                .embededInNavigation(
                    options: [.navigationType(type: .large)],
                    tracking: ForeverNavigationDetentType.changeCode
                )
        }
        .environmentObject(foreverNavigationVm)

    }
}

private enum ForeverNavigationDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .forever:
            return .init(describing: ForeverView.self)
        case .changeCode:
            return .init(describing: ChangeCodeView.self)
        }
    }

    case forever
    case changeCode

}

#Preview {
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
