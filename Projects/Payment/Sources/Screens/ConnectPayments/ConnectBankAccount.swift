import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ConnectBankAccount: View {
    let setupType: SetupType
    let urlScheme: String

    public init(
        setupType: SetupType,
        urlScheme: String = Bundle.main.urlScheme ?? ""
    ) {
        self.setupType = setupType
        self.urlScheme = urlScheme
    }

    public var body: some View {
        switch Dependencies.featureFlags().paymentType {
        case .trustly:
            DirectDebitSetup(setupType: setupType)
        case .adyen:
            DirectDebitSetup(setupType: setupType)
        }
    }

}

extension ConnectBankAccount {
    @JourneyBuilder
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ success: Bool, _ paymentConnectionID: String?) -> Next
    ) -> some JourneyPresentation {

        HostingJourney(
            PaymentStore.self,
            rootView: ConnectBankAccount(setupType: .initial),
            style: .detented(.large),
            options: [.defaults, .autoPopSelfAndSuccessors]
        ) { action in
            ContinueJourney()
        }
    }

    /// Sets up payment and then dismisses
    public var journeyThenDismiss: some JourneyPresentation {
        journey { _, _ in
            return PopJourney()
        }
    }
}
