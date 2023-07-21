import Flow
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hGraphQL

public struct PaymentSetup {
    let setupType: SetupType
    let urlScheme: String

    public enum SetupType {
        case initial
        case preOnboarding(monthlyNetCost: MonetaryAmount?)
        case replacement, postOnboarding
    }

    public init(
        setupType: SetupType,
        urlScheme: String = Bundle.main.urlScheme ?? ""
    ) {
        self.setupType = setupType
        self.urlScheme = urlScheme
    }
}

extension PaymentSetup: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<Either<Bool, AdyenOptions>>) {
        switch hAnalyticsExperiment.paymentType {
        case .trustly:
            let (viewController, result) = DirectDebitSetup(setupType: setupType).materialize()
            return (viewController, result.map { .left($0) })
        case .adyen:
            if case let .preOnboarding(monthlyNetCost) = setupType, let monthlyNetCost = monthlyNetCost {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                store.send(.setMonthlyNetCost(cost: monthlyNetCost))
            }

            let (viewController, result) = AdyenPayInSync(setupType: setupType, urlScheme: urlScheme).materialize()
            return (
                viewController,
                result.map { adyenPayInResult in
                    if let options = adyenPayInResult.left {
                        return .right(options)
                    }

                    return .left(true)
                }
            )
        }
    }
}

extension PaymentSetup {

    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ success: Bool, _ paymentConnectionID: String?) -> Next
    ) -> some JourneyPresentation {
        Journey(
            self,
            style: .detented(.large),
            options: [.defaults, .autoPopSelfAndSuccessors]
        ) { result in
            let store: PaymentStore = globalPresentableStoreContainer.get()
            if let success = result.left {
                next(success, store.state.paymentConnectionID)
            } else if let options = result.right {
                Journey(AdyenPayIn(adyenOptions: options, urlScheme: Bundle.main.urlScheme ?? "")) { success in
                    next(success, store.state.paymentConnectionID)
                }
                .withJourneyDismissButton
            }
        }
    }

    /// Sets up payment and then dismisses
    public var journeyThenDismiss: some JourneyPresentation {
        journey { _, _ in
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(.load)
            return PopJourney()
        }
    }
}
