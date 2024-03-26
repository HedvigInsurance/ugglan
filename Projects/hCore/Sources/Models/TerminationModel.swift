public struct TerminationConfirmConfig: Codable & Equatable & Hashable {
    public var contractId: String
    public var image: PillowType?
    public var contractDisplayName: String
    public var contractExposureName: String
    public var activeFrom: String?
    public var isDeletion: Bool?

    public init(
        contractId: String,
        image: PillowType?,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String? = nil
    ) {
        self.contractId = contractId
        self.image = image
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom
    }
}
