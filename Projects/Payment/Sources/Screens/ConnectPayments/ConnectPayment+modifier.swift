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
                    forPayin: model.forPayin,
                    forPayout: model.forPayout,
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
        forPayin: Bool = true,
        forPayout: Bool = true,
        onSuccess: (() -> Void)? = nil
    ) {
        Task { @MainActor [weak self] in
            self?.setupTypeNavigationModel = .init(
                forPayin: forPayin,
                forPayout: forPayout,
                onSuccess: onSuccess
            )
        }
    }
}

struct SetupTypeNavigationModel: Identifiable {
    let id: String = UUID().uuidString
    let forPayin: Bool
    let forPayout: Bool
    let onSuccess: (() -> Void)?
}

extension SetupTypeNavigationModel: Equatable {
    static func == (lhs: SetupTypeNavigationModel, rhs: SetupTypeNavigationModel) -> Bool {
        lhs.id == rhs.id
    }
}
