import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct ConnectBankAccount {
    let setupType: PaymentSetup.SetupType
    let urlScheme: String

    public init(
        setupType: PaymentSetup.SetupType,
        urlScheme: String = Bundle.main.urlScheme ?? ""
    ) {
        self.setupType = setupType
        self.urlScheme = urlScheme
    }
}

extension ConnectBankAccount: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<Either<Bool, Bool>>) {
        var variant = ApplicationContext.shared.unleashClient.getVariant(name: "payment_type")
        if variant.enabled {
            switch variant.name {
            case "trustly":
                let (viewController, result) = DirectDebitSetup(setupType: setupType).materialize()
                return (viewController, result.map { .left($0) })
            case "adyen":
                let (viewController, result) = AdyenSetup(setupType: setupType).materialize()
                return (viewController, result.map { .left($0) })
            default:
                let (viewController, result) = DirectDebitSetup(setupType: setupType).materialize()
                return (viewController, result.map { .left($0) })
            }
        }
        let (viewController, result) = DirectDebitSetup(setupType: setupType).materialize()
        return (viewController, result.map { .left($0) })
    }
}

extension ConnectBankAccount {
    @JourneyBuilder
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ success: Bool, _ paymentConnectionID: String?) -> Next
    ) -> some JourneyPresentation {
        Journey(
            self
        ) { result in
            let store: PaymentStore = globalPresentableStoreContainer.get()
            if let success = result.left {
                next(success, store.state.paymentConnectionID)
            } else if let options = result.right {
                next(options, store.state.paymentConnectionID)
            }
        }
        .setStyle(.detented(.large))
        .setOptions([.defaults, .autoPopSelfAndSuccessors])
    }

    /// Sets up payment and then dismisses
    public var journeyThenDismiss: some JourneyPresentation {
        journey { _, _ in
            return PopJourney()
        }
    }
}
