import AppStateContainer
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct AddMissingPetChipIdBottomSheet: View {
    @State private var vm: AddMissingPetChipIdViewModel
    @Binding private var detentOptions: DetentPresentationOption

    init(_ vm: AddMissingPetChipIdViewModel, detentOptions: Binding<DetentPresentationOption>) {
        self._vm = State(wrappedValue: vm)
        self._detentOptions = detentOptions
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    ContractInformation(
                        title: vm.contract.currentAgreement!.productVariant.displayName,
                        subtitle: vm.contract.exposureDisplayNameShort,
                        pillowImage: vm.contract.typeOfContract.pillowType.bgImage
                    )
                    .padding(.padding16)
                    .wrapWithBorder()

                    hFloatingTextField(
                        masking: vm.petChipIdMasking,
                        value: $vm.petChipId,
                        focus: .constant(MissingPetChipIdType.single),
                        focusValue: .single,
                        placeholder: L10n.chipIdLabel,
                        error: $vm.fieldError,
                        textFieldPlaceholder: "XXX XXX XXX XXX XXX"
                    )

                    VStack(spacing: .padding8) {
                        hSaveButton(.primary) { vm.addMissingPetChipId() }
                            .disabled(!vm.canProceed)
                            .hButtonIsLoading(vm.isLoading)

                        hCancelButton { vm.dismiss() }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .navigationTitle(L10n.chipIdTopTitle)
        .disabled(vm.isLoading)
        .onChange(of: vm.isLoading) { _, isLoading in
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

enum MissingPetChipIdType: Hashable {
    case single
}

@MainActor
@Observable
class AddMissingPetChipIdViewModel {
    @ObservationIgnored @AppState private var contractStore: ContractStore
    private let service = PetChipIdService()
    let router = NavigationRouter()

    let contract: Contract
    let petChipIdMasking = Masking(type: .petChipId)
    var petChipId: String = ""
    var isLoading = false
    var fieldError: String?
    @ObservationIgnored var canProceed: Bool { petChipIdMasking.isValid(text: petChipId) }

    init(contract: Contract) {
        self.contract = contract
    }

    func addMissingPetChipId() {
        withAnimation {
            isLoading = true
            fieldError = nil
        }

        Task {
            do {
                let petChipId = petChipIdMasking.unmaskedValue(text: petChipId)
                try await service.addMissing(
                    petChipId: petChipId,
                    for: contract.id
                )
                await contractStore.fetchContracts()
                NotificationCenter.default.post(
                    name: .petChipIdAdded,
                    object: PetIdAddedModel(contractId: contract.id, chipId: petChipId)
                )
                Toasts.success()
                dismiss()
            } catch let error as PetChipIdError {
                withAnimation {
                    fieldError = error.message
                    isLoading = false
                }
            } catch {
                withAnimation {
                    fieldError = L10n.somethingWentWrong
                    isLoading = false
                }
            }
        }
    }

    func dismiss() {
        router.dismiss()
    }
}

public struct PetIdAddedModel {
    public let contractId: String
    public let chipId: String

    public init(contractId: String, chipId: String) {
        self.contractId = contractId
        self.chipId = chipId
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PetChipIdClient in PetChipIdClientDemo() })

    let variant = ProductVariant(
        termsVersion: "",
        typeOfContract: TypeOfContract.seDogStandard.rawValue,
        perils: [],
        insurableLimits: [],
        documents: [],
        displayName: "Hundförsäkring",
        displayNameTier: "Standard",
        tierDescription: nil
    )
    let agreement = Agreement(
        id: "agreementId",
        basePremium: .sek(200),
        itemCost: nil,
        displayItems: [],
        productVariant: variant,
        addonVariant: []
    )
    let contract = Contract(
        id: "contractId",
        currentAgreement: agreement,
        exposureDisplayName: "Fido ∙ Golden retriever",
        exposureDisplayNameShort: "Fido",
        masterInceptionDate: "2024-01-01",
        terminationDate: nil,
        supportsAddressChange: false,
        supportsCoInsured: false,
        supportsCoOwners: false,
        supportsTravelCertificate: false,
        supportsChangeTier: false,
        supportsTermination: false,
        upcomingChangedAgreement: nil,
        upcomingRenewal: nil,
        firstName: "",
        lastName: "",
        ssn: nil,
        typeOfContract: .seDogStandard,
        coInsured: [],
        coOwners: [],
        missingPetChipId: true
    )
    return AddMissingPetChipIdBottomSheet(
        .init(contract: contract),
        detentOptions: .constant(.alwaysOpenOnTop)
    )
}
