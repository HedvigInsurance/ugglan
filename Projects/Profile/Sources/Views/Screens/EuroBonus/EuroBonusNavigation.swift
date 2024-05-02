import SwiftUI
import hCore
import hCoreUI

public class EuroBonusNavigationViewModel: ObservableObject {
    @Published var isChangeEuroBonusPresented = false
    @Published var isSuccessChangeEuroBonusPresented = false

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
        .detent(
            presented: $euroBonusNavigationViewModel.isChangeEuroBonusPresented,
            style: .height
        ) {
            ChangeEuroBonusView()
                .configureTitle(L10n.SasIntegration.enterYourNumber)
                .embededInNavigation(options: .navigationType(type: .large))
        }
    }
}

#Preview{
    EuroBonusNavigation()
}
