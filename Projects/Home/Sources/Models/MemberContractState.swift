import Foundation

public enum MemberContractState: String, Codable, Equatable, CaseIterable {
    case terminated
    case future
    case active
    case loading
}
