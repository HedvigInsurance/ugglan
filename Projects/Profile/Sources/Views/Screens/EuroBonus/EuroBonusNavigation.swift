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
    @StateObject var euroBonusNavigationViewModel = EuroBonusNavigationViewModel()

    public var body: some View {
        RouterHost(router: router) {
            EuroBonusView()
                .configureTitle(L10n.SasIntegration.title)
        }
        .environmentObject(euroBonusNavigationViewModel)
        .environmentObject(router)
        .detent(
            presented: $euroBonusNavigationViewModel.isChangeEuroBonusPresented,
            style: .height
        ) {
            ChangeEuroBonusView()
                .configureTitle(L10n.SasIntegration.enterYourNumber)
                .routerDestination(for: EuroBonusRouterType.self) { routerType in
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
    EuroBonusNavigation()
}
