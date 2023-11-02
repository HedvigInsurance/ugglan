import Foundation
import hGraphQL

public struct CoInsuredModel: Codable, Hashable, Equatable {
//    let firstName: String?
//    let lastName: String?
    public let SSN: String?
    public let needsMissingInfo: Bool
    public var fullName: String?
    
    public init(
        data: OctopusGraphQL.CoInsuredFragment
    ) {
        self.SSN = data.birthdate
        self.fullName = data.fullName
        self.needsMissingInfo = data.needsMissingInfo
    }

    public init(
//        firstName: String? = nil,
//        lastName: String? = nil,
        fullName: String? = nil,
        SSN: String? = nil,
        needsMissingInfo: Bool
    ) {
//        self.firstName = firstName
//        self.lastName = lastName
        self.SSN = SSN
        self.fullName = fullName
        self.needsMissingInfo = needsMissingInfo
    }
}
