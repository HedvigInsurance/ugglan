import Combine
import Presentation
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
    @State var cancellable: AnyCancellable?

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
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    router.dismiss()
                                }
                            }
                    }
                }
                .configureTitle(L10n.changeAddressAddBuilding)
                .embededInNavigation(options: [.navigationType(type: .large)])
        }
        .onAppear {
            let store: ForeverStore = globalPresentableStoreContainer.get()
            cancellable = store.actionSignal.publisher.sink { _ in
            } receiveValue: { action in
                switch action {
                case .showChangeCodeSuccess:
                    router.push(ForeverRouterActions.success)
                case .dismissChangeCodeDetail:
                    router.dismiss()
                default:
                    break
                }
            }
        }
    }
}

#Preview{
    ForeverNavigation()
}
