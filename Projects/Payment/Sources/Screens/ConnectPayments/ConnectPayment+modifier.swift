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

    public func set(for setupType: SetupType?) {
        Task { @MainActor [weak self] in
            self?.setupTypeNavigationModel = .init(setUpType: setupType)
        }
    }
}

struct SetupTypeNavigationModel: Equatable, Identifiable {
    init(
        setUpType: SetupType?
    ) {
        self.setUpType = setUpType
    }

    let id: String = UUID().uuidString
    let setUpType: SetupType?
}
