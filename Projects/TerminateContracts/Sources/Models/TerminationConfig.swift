public struct TerminationConfirmConfig: Codable & Equatable & Hashable {
    public var contractId: String
    public var contractDisplayName: String
    public var contractExposureName: String
    public var activeFrom: String?

    public init(
        contractId: String,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String?
    ) {
        self.contractId = contractId
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom

    }
}
