import Foundation
import SwiftUI
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
        options: DetentPresentationOption = .alwaysOpenOnTop
    ) -> some View {
        modifier(MissingPetChipIdsCoordinator(input: input, options: options))
    }
}

struct AddMissingPetChipIdBottomSheet: View {
    @StateObject private var vm: AddMissingPetChipIdViewModel
    @Binding var detentOptions: DetentPresentationOption

    init(_ vm: AddMissingPetChipIdViewModel, detentOptions: Binding<DetentPresentationOption>) {
        self._vm = StateObject(wrappedValue: vm)
        self._detentOptions = detentOptions
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
                        error: $vm.fieldError,
                        textFieldPlaceholder: "XXX XXX XXX XXX XXX"
                    )

                    VStack(spacing: .padding8) {
                        hSaveButton(.primary) { [weak vm] in
                            vm?.addMissingPetChipId()
                        }
                        .disabled(!vm.canProceed)
                        .hButtonIsLoading(vm.isLoading)

                        hCancelButton { [weak vm] in vm?.dismiss() }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.chipIdTopTitle)
        .disabled(vm.isLoading)
        .onChange(of: vm.isLoading) { isLoading in
            if isLoading {
                detentOptions.insert(.disableDismissOnScroll)
            } else {
                detentOptions.remove(.disableDismissOnScroll)
            }
        }
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
    @Published var isLoading = false
    @Published var fieldError: String?
    var canProceed: Bool { petChipIdMasking.isValid(text: petChipId) }

    init(contract: Contract) {
        self.contract = contract
    }

    public func addMissingPetChipId() {
        isLoading = true
        fieldError = nil

        Task {
            do {
                if let petError = try await service.addMissing(
                    petChipId: petChipIdMasking.unmaskedValue(text: petChipId),
                    for: contract.id
                ) {
                    fieldError = petError.message
                    isLoading = false
                } else {
                    dismiss()
                }
            } catch {
                isLoading = false
                fieldError = L10n.somethingWentWrong
            }
        }
    }

    func dismiss() {
        router.dismiss()
    }
}
