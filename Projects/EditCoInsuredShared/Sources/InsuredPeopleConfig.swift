import Foundation

public struct InsuredPeopleConfig: Codable & Equatable & Hashable, Identifiable, Sendable {
    public var id: String
    public var contractCoInsured: [CoInsuredModel]
    public var contractId: String
    public var activeFrom: String?
    public var numberOfMissingCoInsured: Int
    public var numberOfMissingCoInsuredWithoutTermination: Int
    public let displayName: String
    public let exposureDisplayName: String?
    public let preSelectedCoInsuredList: [CoInsuredModel]
    public let contractDisplayName: String
    public let holderFirstName: String
    public let holderLastName: String
    public let holderSSN: String?
    public var holderFullName: String {
        return holderFirstName + " " + holderLastName
    }

    public var fromInfoCard: Bool

    public init() {
        self.contractCoInsured = []
        self.contractId = ""
        self.activeFrom = nil
        self.numberOfMissingCoInsured = 0
        self.numberOfMissingCoInsuredWithoutTermination = 0
        self.displayName = ""
        self.exposureDisplayName = nil
        self.holderFirstName = ""
        self.holderLastName = ""
        self.holderSSN = nil
        self.preSelectedCoInsuredList = []
        self.contractDisplayName = ""
        self.fromInfoCard = false
        self.id = UUID().uuidString
    }

    public init(
        id: String,
        contractCoInsured: [CoInsuredModel],
        contractId: String,
        activeFrom: String?,
        numberOfMissingCoInsured: Int,
        numberOfMissingCoInsuredWithoutTermination: Int,
        displayName: String,
        exposureDisplayName: String?,
        preSelectedCoInsuredList: [CoInsuredModel],
        contractDisplayName: String,
        holderFirstName: String,
        holderLastName: String,
        holderSSN: String?,
        fromInfoCard: Bool
    ) {
        self.id = id
        self.contractCoInsured = contractCoInsured
        self.contractId = contractId
        self.activeFrom = activeFrom
        self.numberOfMissingCoInsured = numberOfMissingCoInsured
        self.numberOfMissingCoInsuredWithoutTermination = numberOfMissingCoInsuredWithoutTermination
        self.displayName = displayName
        self.exposureDisplayName = exposureDisplayName
        self.preSelectedCoInsuredList = preSelectedCoInsuredList
        self.contractDisplayName = contractDisplayName
        self.holderFirstName = holderFirstName
        self.holderLastName = holderLastName
        self.holderSSN = holderSSN

        self.fromInfoCard = fromInfoCard
    }
}
