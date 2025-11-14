import hCore

public struct TerminationConfirmConfig: Codable & Equatable & Hashable & Sendable {
    public var contractId: String
    public var contractDisplayName: String
    public var contractExposureName: String
    public var activeFrom: String?
    public var typeOfContract: TypeOfContract?

    public init(
        contractId: String,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String?,
        typeOfContract: TypeOfContract?
    ) {
        self.contractId = contractId
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom
        self.typeOfContract = typeOfContract
    }
}
