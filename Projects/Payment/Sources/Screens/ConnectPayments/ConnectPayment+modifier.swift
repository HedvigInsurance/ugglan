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
                .onDeinit {
                    Task {
                        await model.onDeinit?()
                    }
                }
            }
    }
}

@MainActor
public class ConnectPaymentViewModel: ObservableObject {
    @Published public internal(set) var setupTypeNavigationModel: SetupTypeNavigationModel?
    public init() {}

    public func set(
        onSuccess: (() -> Void)? = nil,
        onDeinit: (() async -> Void)? = nil
    ) {
        Task { @MainActor [weak self] in
            self?.setupTypeNavigationModel = .init(
                onSuccess: onSuccess,
                onDeinit: onDeinit
            )
        }
    }
}

public struct SetupTypeNavigationModel: Identifiable {
    public let id: String = UUID().uuidString
    public let onSuccess: (() -> Void)?
    public let onDeinit: (() async -> Void)?
}

extension SetupTypeNavigationModel: Equatable {
    public static func == (lhs: SetupTypeNavigationModel, rhs: SetupTypeNavigationModel) -> Bool {
        lhs.id == rhs.id
    }
}
