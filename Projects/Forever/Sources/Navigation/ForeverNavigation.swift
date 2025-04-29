import Environment
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ForeverNavigationViewModel: ObservableObject {
    @Published var isChangeCodePresented = false
    @Published var foreverData: ForeverData?
    @Inject var foreverService: ForeverClient
    @Published var viewState: ProcessingState = .loading

    func fetchForeverData() async throws {
        if foreverData == nil {
            withAnimation {
                viewState = .loading
            }
        }
        do {
            let data = try await self.foreverService.getMemberReferralInformation()
            foreverData = data
            withAnimation {
                viewState = .success
            }
        } catch let exception {
            withAnimation {
                viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
    }

    func shareCode(code: String, modalPresentationWrapperVM: ModalPresentationSourceWrapperViewModel) {
        let discount = foreverData?.monthlyDiscountPerReferral.formattedAmount
        let url =
            "\(Environment.current.webBaseURL)/\(hCore.Localization.Locale.currentLocale.value.webPath)/forever/\(code)"
        let message = L10n.referralSmsMessage(discount ?? "", url)

        let activityVC = UIActivityViewController(
            activityItems: [message as Any],
            applicationActivities: nil
        )
        modalPresentationWrapperVM.present(activity: activityVC)
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
            ChangeCodeView(foreverNavigationVm: foreverNavigationVm)
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
        .environmentObject(Router())
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
