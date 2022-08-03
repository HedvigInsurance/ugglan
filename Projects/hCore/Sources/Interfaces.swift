import SwiftUI

public protocol ClaimsProviding {
    associatedtype ClaimsType: View
    associatedtype CommonClaimsType: View

    var claims: ClaimsType { get }
    var commonClaims: CommonClaimsType { get }

    var claimSubmission: () -> Void { get }
}
