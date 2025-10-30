import SwiftUI
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
                transitionType: .detent(style: [.large]),
                options: .constant([.disableDismissOnScroll, .withoutGrabber, .alwaysOpenOnTop])
            ) { _ in
                DirectDebitSetup()
            }
    }
}

@MainActor
public class ConnectPaymentViewModel: ObservableObject {
    @Published var setupTypeNavigationModel: SetupTypeNavigationModel?
    public init() {}

    public func set() {
        Task { @MainActor [weak self] in
            self?.setupTypeNavigationModel = .init()
        }
    }
}

struct SetupTypeNavigationModel: Equatable, Identifiable {
    let id: String = UUID().uuidString
}
