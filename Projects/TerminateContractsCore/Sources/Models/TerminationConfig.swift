import hCore

public struct TerminationConfirmConfig: Codable & Equatable & Hashable & Sendable {
    public var contractId: String
    public var contractDisplayName: String
    public var contractExposureName: String
    public var activeFrom: String?
    public var typeOfContract: TypeOfContract?
    public var supportsWithdrawal: Bool
    public var supportsTermination: Bool

    public init(
        contractId: String,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String?,
        typeOfContract: TypeOfContract?,
        supportsWithdrawal: Bool = false,
        supportsTermination: Bool = true
    ) {
        self.contractId = contractId
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom
        self.typeOfContract = typeOfContract
        self.supportsWithdrawal = supportsWithdrawal
        self.supportsTermination = supportsTermination
    }

    /// The contract can only be withdrawn, so the flow skips the withdraw-or-cancel choice.
    public var isWithdrawalOnly: Bool {
        supportsWithdrawal && !supportsTermination
    }
}
