import Foundation
import hGraphQL

extension GiraffeGraphQL.InsuranceType {
    var isStudent: Bool {
        switch self {
        case .studentBrf, .studentRent: return true
        default: return false
        }
    }

    var isOwnedApartment: Bool {
        switch self {
        case .studentBrf, .brf: return true
        default: return false
        }
    }

    var isApartment: Bool {
        switch self {
        case .studentBrf, .studentRent, .brf, .rent: return true
        default: return false
        }
    }
}
