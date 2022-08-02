import Foundation
import SwiftUI

public protocol ClaimsProviding {
    var claims: AnyView { get }
    var commonClaims: AnyView { get }
}
