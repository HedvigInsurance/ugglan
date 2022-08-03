import Factory
import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct Claims {
    @PresentableStore var store: ClaimsStore
    let pollTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    func claimSubmission() {
        store.send(.submitNewClaim)
    }

    init() {}
}

extension Claims: View {
    func fetch() {
        store.send(.fetchClaims)
    }

    var body: some View {
        ClaimSectionLoading()
            .onReceive(pollTimer) { _ in
                fetch()
            }
            .onAppear {
                fetch()
            }
    }
}

struct ClaimsProvider: ClaimsProviding {
    var claims: some View {
        Claims()
    }

    var commonClaims: some View {
        CommonClaimsView()
    }

    var claimSubmission: () -> Void {
        Claims().claimSubmission
    }
}

extension Container {
    public static var claimsProvider: some ClaimsProviding = ClaimsProvider()
}
