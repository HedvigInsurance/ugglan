import Flow
import Foundation
import Presentation
import UIKit
import hCore

public struct PaymentSetup {
    let setupType: SetupType
    let urlScheme: String

    public enum SetupType { case initial, replacement, postOnboarding }

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
        switch Localization.Locale.currentLocale.market {
        case .se:
            let (viewController, result) = DirectDebitSetup(setupType: setupType).materialize()
            return (viewController, result.map { .left($0) })
        case .no, .dk, .fr:
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
        @JourneyBuilder _ next: @escaping (_ success: Bool) -> Next
    ) -> some JourneyPresentation {
        Journey(
            self,
            style: .detented(.large),
            options: [.defaults, .autoPopSelfAndSuccessors]
        ) { result in
            if let success = result.left {
                next(success)
            } else if let options = result.right {
                Journey(AdyenPayIn(adyenOptions: options, urlScheme: Bundle.main.urlScheme ?? "")) { success in
                    next(success)
                }
                .withJourneyDismissButton
            }
        }
    }
    
    /// Sets up payment and then dismisses
    public var journeyThenDismiss: some JourneyPresentation {
        journey { _ in
            DismissJourney()
        }
    }
}
