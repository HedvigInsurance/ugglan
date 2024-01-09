import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct Claims {
    @PresentableStore var store: ClaimsStore
    let pollTimer: Publishers.Autoconnect<Timer.TimerPublisher>

    public init() {
        let store: ClaimsStore = globalPresentableStoreContainer.get()
        let count = store.state.claims?.count ?? 1
        let refreshOn: Int = {
            if count == 0 {
                return 5
            } else {
                return min(count * 5, 20)
            }
        }()
        pollTimer = Timer.publish(every: TimeInterval(refreshOn), on: .main, in: .common).autoconnect()
    }
}

extension Claims: View {
    func fetch() {
        store.send(.fetchClaims)
    }

    public var body: some View {
        ClaimSectionLoading()
            .onReceive(pollTimer) { _ in
                if ApplicationContext.shared.isLoggedIn {
                    fetch()
                } else {
                    pollTimer.upstream.connect().cancel()
                }
            }
            .onAppear {
                fetch()
            }
    }
}
