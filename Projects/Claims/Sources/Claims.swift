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

    public func claimSubmission() {
        store.send(.submitNewClaim)
    }

    public init() {}
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

public protocol ClaimsProviding {
    var claims: AnyView { get }
    var commonClaims: AnyView { get }
}

struct ClaimsProvider: ClaimsProviding {
    var claims: AnyView {
        Claims().typeErased
    }
    
    var commonClaims: AnyView {
        CommonClaimsView().typeErased
    }
}

private struct ClaimsKey: InjectionKey {
    static var currentValue: ClaimsProviding = ClaimsProvider()
}

extension InjectedValues {
    public var claimsProvider: ClaimsProviding {
        get { Self[ClaimsKey.self] }
        set { Self[ClaimsKey.self] = newValue }
    }
}

extension View {
    /// Returns a type-erased version of the view.
    public var typeErased: AnyView { AnyView(self) }
}
