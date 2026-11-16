import Foundation
import SwiftUI
import UIKit
import hCore
import hCoreUI

private struct MissingPetChipIdsCoordinator: ViewModifier {
    @Binding fileprivate var input: MissingPetChipIdInput?
    @State fileprivate var options: DetentPresentationOption

    @State private var addMissingPetChipIdInput: AddMissingPetChipIdInput?
    @State private var selectContractInput: SelectContractInput?

    public func body(content: Content) -> some View {
        content
            .detent(item: $addMissingPetChipIdInput, options: $options) { addMissingPetChipIdInput in
                AddMissingPetChipIdBottomSheet(
                    .init(contract: addMissingPetChipIdInput.contract),
                    detentOptions: $options
                )
            }
            .detent(item: $selectContractInput) { selectContractInput in
                MissingPetChipIdSelectInsuranceScreen(
                    contracts: selectContractInput.contracts
                ) { selectedContract in
                    self.selectContractInput = nil
                    self.addMissingPetChipIdInput = .init(contract: selectedContract)
                }
            }
            .onChange(of: input) { _, input in
                guard let contracts = input?.contracts, !contracts.isEmpty else { return }

                if contracts.count == 1, let contract = contracts.first {
                    addMissingPetChipIdInput = .init(contract: contract)
                } else {
                    selectContractInput = .init(contracts: contracts)
                }

                self.input = nil
            }
    }
}

extension View {
    public func handleMissingChipIds(
        input: Binding<MissingPetChipIdInput?>,
        options: DetentPresentationOption = .alwaysOpenOnTop
    ) -> some View {
        modifier(MissingPetChipIdsCoordinator(input: input, options: options))
    }
}

private struct AddMissingPetChipIdInput: Identifiable & Equatable {
    var id: String { contract.id }
    let contract: Contract
}

private struct SelectContractInput: Identifiable & Equatable {
    var id: String { contracts.map(\.id).joined(separator: "-") }
    let contracts: [Contract]
}
