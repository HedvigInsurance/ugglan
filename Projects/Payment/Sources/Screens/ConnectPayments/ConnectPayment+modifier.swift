import SwiftUI
import hCore
import hCoreUI

extension View {
    public func handleConnectPayment(with vm: ConnectPaymentViewModel) -> some View {
        modifier(ConnectPayment(vm: vm))
    }
}

struct ConnectPayment: ViewModifier {
    @ObservedObject var vm: ConnectPaymentViewModel
    @EnvironmentObject var router: Router

    func body(content: Content) -> some View {
        content
            .detent(
                item: $vm.connectPaymentModel,
                style: .large,
                options: .constant([.disableDismissOnScroll, .withoutGrabber])
            ) { setupTypeModel in
                let featureFlags: FeatureFlags = Dependencies.shared.resolve()
                switch featureFlags.paymentType {
                case .adyen:
                    EmptyView()
                        .onAppear {
                            Task {
                                let paymentServcice: AdyenService = Dependencies.shared.resolve()
                                do {
                                    let url = try await paymentServcice.getAdyenUrl()
                                    router.push(PaymentsRouterAction.openUrl(url: url))
                                } catch {
                                    //we are not so concerned about this
                                }
                            }
                        }

                case .trustly:
                    DirectDebitSetup()
                        .configureTitle(
                            setupTypeModel.setUpType == .replacement
                                ? L10n.PayInIframeInApp.connectPayment : L10n.PayInIframePostSign.title
                        )
                        .embededInNavigation(options: .navigationType(type: .large))
                }
            }
    }
}

public class ConnectPaymentViewModel: ObservableObject {
    @Published public var connectPaymentModel: SetupTypeNavigationModel?
    public init() {}
}

public struct SetupTypeNavigationModel: Equatable, Identifiable {

    public init(
        setUpType: SetupType?
    ) {
        self.setUpType = setUpType
    }

    public var id: String?
    var setUpType: SetupType?
}
