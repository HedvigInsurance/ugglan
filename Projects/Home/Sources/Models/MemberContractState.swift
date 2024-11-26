import Foundation

public enum MemberContractState: String, Codable, Equatable, CaseIterable, Sendable {
    case terminated
    case future
    case active
    case loading
}
