import Foundation
import SwiftUI
import hCore
import hCoreUI

private struct MissingPetChipIdsCoordinator: ViewModifier {
    @Binding fileprivate var input: MissingPetChipIdInput?
    @Binding fileprivate var options: DetentPresentationOption

    @State private var singleContractInput: SingleContractInput?
    @State private var multipleContractInput: MultipleContractInput?

    public func body(content: Content) -> some View {
        content
            .detent(item: $singleContractInput) { singleContractInput in
                AddMissingPetChipIdBottomSheet(singleContractInput.id)
            }
            .modally(item: $multipleContractInput) { multipleContractInput in
                // TODO: contract selections
            }
            .onChange(of: input) { input in
                guard let contracts = input?.contracts, !contracts.isEmpty else { return }
                self.input = nil

                if contracts.count == 1 {
                    singleContractInput = .init(id: contracts.first!.id)
                } else {
                    multipleContractInput = .init(contracts: contracts)
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
    @EnvironmentObject var navigationVm: ContractsNavigationViewModel
    let contractId: String
    let petChipIdMaksing = Masking(type: .petChipId)
    @State var petChipId: String = ""

    @State private var isLoading: Bool = false
    @State private var error: String? = nil

    let router = Router()
    let service = PetService()

    init(_ contractId: String) {
        self.contractId = contractId
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
                                    for: contractId
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

private struct SingleContractInput: Identifiable & Equatable {
    let id: String
}

private struct MultipleContractInput: Identifiable & Equatable {
    var id: String { contracts.map(\.id).joined(separator: "-") }

    let contracts: [Contract]
}

#Preview {
    AddMissingPetChipIdBottomSheet("")
}
