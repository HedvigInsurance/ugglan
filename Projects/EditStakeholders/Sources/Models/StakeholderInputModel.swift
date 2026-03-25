public struct StakeholderInputModel: Identifiable, Equatable {
    public var id: String?
    let actionType: StakeholderAction
    let stakeholderModel: Stakeholder
    let title: String
    let contractId: String
}
