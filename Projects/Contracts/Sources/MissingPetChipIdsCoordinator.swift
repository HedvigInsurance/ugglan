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
                AddMissingPetChipIdBottomSheet(.init(contract: addMissingPetChipIdInput.contract))
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
    @StateObject private var vm: AddMissingPetChipIdViewModel

    init(_ vm: AddMissingPetChipIdViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    hFloatingTextField(
                        masking: vm.petChipIdMasking,
                        value: $vm.petChipId,
                        equals: .constant(MissingPetChipIdType.single),
                        focusValue: .single,
                        placeholder: L10n.chipIdLabel,
                        //                        error: $vm.petError?.message,
                        textFieldPlaceholder: "XXX XXX XXX XXX XXX",
                    )

                    VStack(spacing: .padding8) {
                        hSaveButton(.primary) {
                            [weak vm] in vm?.addMissingPetChipId()
                        }
                        .disabled(!vm.canProceed)
                        .hButtonIsLoading(vm.processingState == .loading)
                        hCancelButton { [weak vm] in vm?.dismiss() }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.chipIdTopTitle)
        .embededInNavigation(router: vm.router, tracking: self)
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

@MainActor
class AddMissingPetChipIdViewModel: ObservableObject {
    private let service = PetService()
    let router = Router()
    let contract: Contract
    let petChipIdMasking = Masking(type: .petChipId)
    @Published var petChipId: String = ""
    @Published var processingState = ProcessingState.success
    @Published var petError: PetError? = nil
    var canProceed: Bool { petChipIdMasking.isValid(text: petChipId) }

    init(contract: Contract) {
        self.contract = contract
    }

    public func addMissingPetChipId() {
        processingState = .loading
        petError = nil

        Task {
            do {
                if let petError = try await service.addMissing(
                    petChipId: petChipIdMasking.unmaskedValue(text: petChipId),
                    for: contract.id
                ) {
                    self.petError = petError
                    processingState = .success
                } else {
                    dismiss()
                }
            } catch let error {
                processingState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func dismiss() {
        router.dismiss()
    }
}
