import Foundation

struct CoInsuredModel: Codable, Hashable, Equatable {
    let name: String
    let SSN: String
    var type: CoInsuredType?
}

enum CoInsuredType: String, Codable {
    case deleted
    case added
}
