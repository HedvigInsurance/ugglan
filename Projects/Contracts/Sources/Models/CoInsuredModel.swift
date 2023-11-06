import Foundation

public struct CoInsuredModel: Codable, Hashable, Equatable {
    let name: String?
    let SSN: String?

    public init(
        name: String? = nil,
        SSN: String? = nil
    ) {
        self.name = name
        self.SSN = SSN
    }
}
