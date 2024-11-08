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
                style: [.large],
                options: .constant([.disableDismissOnScroll, .withoutGrabber, .alwaysOpenOnTop])
            ) { setupTypeModel in
                DirectDebitSetup()
            }
    }
}

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

    public init(
        setUpType: SetupType?
    ) {
        self.setUpType = setUpType
    }

    public let id: String = UUID().uuidString
    let setUpType: SetupType?
}
