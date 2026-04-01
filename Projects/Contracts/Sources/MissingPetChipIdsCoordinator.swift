import Foundation
import SwiftUI
import hCore
import hCoreUI

private struct MissingPetChipIdsCoordinator: ViewModifier {
    @Binding fileprivate var input: MissingPetChipIdInput?
    @Binding fileprivate var options: DetentPresentationOption

    @State private var addMissingPetChipIdInput: AddMissingPetChipIdInput?
    @State private var selectContractInput: SelectContractInput?

    public func body(content: Content) -> some View {
        content
            .detent(item: $addMissingPetChipIdInput) { addMissingPetChipIdInput in
                AddMissingPetChipIdBottomSheet(addMissingPetChipIdInput.contract)
            }
            .modally(item: $selectContractInput) { selectContractInput in
                // TODO: contract selections
            }
            .onChange(of: input) { input in
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
        options: Binding<DetentPresentationOption> = .constant(.alwaysOpenOnTop)
    ) -> some View {
        modifier(MissingPetChipIdsCoordinator(input: input, options: options))
    }
}

struct AddMissingPetChipIdBottomSheet: View {
    let contract: Contract
    let petChipIdMaksing = Masking(type: .petChipId)
    @State var petChipId: String = ""

    @State private var isLoading: Bool = false
    @State private var error: String? = nil

    let router = Router()
    let service = PetService()

    init(_ contract: Contract) {
        self.contract = contract
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    hFloatingTextField(
                        masking: petChipIdMaksing,
                        value: $petChipId,
                        equals: .constant(MissingPetChipIdType.single),
                        focusValue: .single,
                        placeholder: L10n.chipIdLabel,
                        error: $error,
                        textFieldPlaceholder: "XXX XXX XXX XXX XXX",
                    )

                    VStack(spacing: .padding8) {
                        hSaveButton(.primary) {
                            Task { [weak service, weak router] in
                                guard let service else { return }
                                let error = try? await service.addMissing(
                                    petChipId: petChipIdMaksing.unmaskedValue(text: petChipId),
                                    for: contract.id
                                )
                                if error == nil { router?.dismiss() }
                            }
                        }
                        .disabled(!petChipIdMaksing.isValid(text: petChipId))
                        hCancelButton { [weak router] in router?.dismiss() }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.chipIdTopTitle)
        .embededInNavigation(router: router, tracking: self)
    }
}

extension AddMissingPetChipIdBottomSheet: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: AddMissingPetChipIdBottomSheet.self)
    }
}

enum MissingPetChipIdType: hTextFieldFocusStateCompliant {
    case single
    static let last: MissingPetChipIdType = .single
    var next: MissingPetChipIdType? { nil }
}

private struct AddMissingPetChipIdInput: Identifiable & Equatable {
    var id: String { contract.id }
    let contract: Contract
}

private struct SelectContractInput: Identifiable & Equatable {
    var id: String { contracts.map(\.id).joined(separator: "-") }
    let contracts: [Contract]
}
