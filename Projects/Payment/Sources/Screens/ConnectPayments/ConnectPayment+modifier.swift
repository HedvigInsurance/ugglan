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

    func body(content: Content) -> some View {
        content
            .detent(
                item: $vm.setupTypeNavigationModel,
                style: .large,
                options: .constant([.disableDismissOnScroll, .withoutGrabber, .alwaysOpenOnTop])
            ) { setupTypeModel in
                DirectDebitSetup()
                    .configureTitle(
                        setupTypeModel.setUpType == .replacement
                            ? L10n.PayInIframeInApp.connectPayment : L10n.PayInIframePostSign.title
                    )
            }
    }
}

public class ConnectPaymentViewModel: ObservableObject {
    @Published var setupTypeNavigationModel: SetupTypeNavigationModel?
    public init() {}
    private let paymentServcice: AdyenService = Dependencies.shared.resolve()

    public func set(for setupType: SetupType?) {
        Task { @MainActor [weak self] in
            let featureFlags: FeatureFlags = Dependencies.shared.resolve()
            switch featureFlags.paymentType {
            case .adyen:
                do {
                    let url = try await self?.paymentServcice.getAdyenUrl()
                    NotificationCenter.default.post(name: .openDeepLink, object: url)
                } catch {
                    //we are not so concerned about this
                }
            case .trustly:
                self?.setupTypeNavigationModel = .init(setUpType: setupType)
            }
        }
    }
}

struct SetupTypeNavigationModel: Equatable, Identifiable {

    public init(
        setUpType: SetupType?
    ) {
        self.setUpType = setUpType
    }

    public let id: String = UUID().uuidString
    let setUpType: SetupType?
}
