import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct Claims {
    @PresentableStore var store: ClaimsStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    public init() {

    }
}

extension Claims: View {
    func fetch() {
        store.send(.fetchClaims)
    }

    public var body: some View {
        ClaimSectionLoading()
            .onReceive(pollTimer) { _ in
                fetch()
            }
            .onAppear {
                fetch()
            }
    }
}

public enum ClaimsResult {
    case submitClaims
    case openFreeTextChat
    case openClaimDetails(claim: Claim)
}

extension Claims {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: ClaimsResult) -> ResultJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: Claims(),
            options: .defaults
        ) { action in
            if case let .openClaimDetails(claim) = action {
                resultJourney(.openClaimDetails(claim: claim))
            } else if case .submitClaims = action {
                resultJourney(.submitClaims)
            } else if case .openFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            }
        }
    }
}
