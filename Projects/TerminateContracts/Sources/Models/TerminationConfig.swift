public struct TerminationConfirmConfig: Codable & Equatable & Hashable {
    public var contractId: String
    public var contractDisplayName: String
    public var contractExposureName: String
    public var activeFrom: String?
    public var isDeletion: Bool?
    public var fromSelectInsurances: Bool

    public init(
        contractId: String,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String? = nil,
        fromSelectInsurances: Bool
    ) {
        self.contractId = contractId
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom
        self.fromSelectInsurances = fromSelectInsurances

    }
}
