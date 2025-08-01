public struct CoInsuredInputModel: Identifiable, Equatable {
    public var id: String?
    let actionType: CoInsuredAction
    let coInsuredModel: CoInsuredModel
    let title: String
    let contractId: String
}
