import SwiftUI
import hCore
import hCoreUI

public class EuroBonusNavigationViewModel: ObservableObject {
    @Published var isChangeEuroBonusPresented = false
}

enum EuroBonusRouterType {
    case successChangeEuroBonus
}

public struct EuroBonusNavigation: View {
    @StateObject var router = Router()
    private let useOwnNavigation: Bool
    @StateObject var euroBonusNavigationViewModel = EuroBonusNavigationViewModel()

    public init(
        useOwnNavigation: Bool
    ) {
        self.useOwnNavigation = useOwnNavigation
    }

    public var body: some View {
        Group {
            if useOwnNavigation {
                RouterHost(router: router) {
                    EuroBonusView()
                        .configureTitle(L10n.SasIntegration.title)
                        .withDismissButton()
                }
            } else {
                EuroBonusView()
                    .configureTitle(L10n.SasIntegration.title)
            }
        }
        .environmentObject(euroBonusNavigationViewModel)
        .detent(
            presented: $euroBonusNavigationViewModel.isChangeEuroBonusPresented,
            style: .height
        ) {
            ChangeEuroBonusView()
                .configureTitle(L10n.SasIntegration.enterYourNumber)
                .routerDestination(for: EuroBonusRouterType.self, options: [.hidesBackButton]) { routerType in
                    switch routerType {
                    case .successChangeEuroBonus:
                        SuccessScreen(title: L10n.SasIntegration.eurobonusConnected)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    router.dismiss()
                                }
                            }
                    }
                }
                .embededInNavigation(options: .navigationType(type: .large))
        }
    }
}

#Preview{
    EuroBonusNavigation(useOwnNavigation: false)
}
