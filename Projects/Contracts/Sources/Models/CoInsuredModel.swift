import Foundation

public struct CoInsuredModel: Codable, Hashable, Equatable {
    let firstName: String
    let lastName: String
    let SSN: String
    var fullName: String {
        return firstName + " " + lastName
    }
}
