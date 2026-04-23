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
                presentationStyle: .detent(style: [.large]),
                options: .constant([.disableDismissOnScroll, .withoutGrabber, .alwaysOpenOnTop])
            ) { model in
                DirectDebitSetup(
                    onSuccess: model.onSuccess
                )
            }
    }
}

@MainActor
public class ConnectPaymentViewModel: ObservableObject {
    @Published var setupTypeNavigationModel: SetupTypeNavigationModel?
    public init() {}

    public func set(
        onSuccess: (() -> Void)? = nil
    ) {
        Task { @MainActor [weak self] in
            self?.setupTypeNavigationModel = .init(
                onSuccess: onSuccess
            )
        }
    }
}

struct SetupTypeNavigationModel: Identifiable {
    let id: String = UUID().uuidString
    let onSuccess: (() -> Void)?
}

extension SetupTypeNavigationModel: Equatable {
    static func == (lhs: SetupTypeNavigationModel, rhs: SetupTypeNavigationModel) -> Bool {
        lhs.id == rhs.id
    }
}
