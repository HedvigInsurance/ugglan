import Foundation

public enum MemberContractState: String, Codable, Equatable {
    case terminated
    case future
    case active
    case loading
}
