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
    let pollTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    public init() {}
}

/* NEW*/
public struct NewClaim: Codable, Hashable, Equatable {

    public init(
        dateOfOccurrence: String,
        location: String
    ) {
        self.dateOfOccurrence = dateOfOccurrence
        self.location = location
    }

    public let dateOfOccurrence: String
    public let location: String

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
