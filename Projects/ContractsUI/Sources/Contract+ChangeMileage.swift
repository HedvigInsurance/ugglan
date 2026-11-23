import ChangeMileageCore
import ContractsCore

extension Contract {
    public var asChangeMileageContract: ChangeMileageContract {
        .init(
            contractId: id,
            displayName: currentAgreement?.productVariant.displayName ?? "",
            exposureName: exposureDisplayName,
            typeOfContract: typeOfContract
        )
    }
}
