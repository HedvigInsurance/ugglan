import Foundation

@MainActor
public protocol ExistingStakeholders: AnyObject {
    func get(contractId: String, stakeholderType: StakeholderType) -> [Stakeholder]
}
