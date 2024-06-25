import EditCoInsuredShared
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct EditContract: View {
    @PresentableStore var store: ContractStore
    @State var selectedType: EditType?
    @State var editTypes: [EditType] = []
    private let contract: Contract?
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel

    public init(id: String) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        contract = store.state.contractForId(id)
        if let contract {
            _editTypes = State(initialValue: EditType.getTypes(for: contract))
        } else {
            _editTypes = State(initialValue: [])
        }
    }
    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    ForEach(editTypes, id: \.rawValue) { editType in
                        hSection {
                            hRow {
                                HStack(spacing: 0) {
                                    hText(editType.title, style: .title3)
                                        .foregroundColor(hTextColor.Opaque.primary)
                                    Spacer()
                                    Circle()
                                        .strokeBorder(
                                            getBorderColor(isSelected: editType == selectedType),
                                            lineWidth: editType == selectedType ? 0 : 1.5
                                        )
                                        .background(
                                            Circle().foregroundColor(retColor(isSelected: editType == selectedType))
                                        )
                                        .frame(width: 28, height: 28)
                                }
                            }
                            .withEmptyAccessory
                            .onTap {
                                withAnimation(Animation.easeInOut(duration: 0.3)) {
                                    selectedType = editType
                                }
                            }
                        }
                    }
                }
                infoView
                hSection {
                    VStack(spacing: 8) {
                        hButton.LargeButton(type: .primary) {
                            contractsNavigationVm.changeYourInformationContract = nil
                            switch selectedType {
                            case .coInsured:
                                if Dependencies.featureFlags().isEditCoInsuredEnabled {
                                    if let contract {
                                        let configContract: InsuredPeopleConfig = .init(
                                            contract: contract,
                                            fromInfoCard: false
                                        )
                                        contractsNavigationVm.editCoInsuredVm.start(fromContract: configContract)
                                    }
                                } else {
                                    NotificationCenter.default.post(name: .openChat, object: nil)
                                }
                            case .changeAddress:
                                contractsNavigationVm.isChangeAddressPresented = true
                            case nil:
                                break
                            }
                        } content: {
                            hText(selectedType?.buttonTitle ?? L10n.generalContinueButton, style: .body1)
                        }
                        .disabled(selectedType == nil)

                        hButton.LargeButton(type: .ghost) {
                            contractsNavigationVm.changeYourInformationContract = nil
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.bottom, .padding16)
            }
        }
        .hDisableScroll
    }

    @ViewBuilder
    var infoView: some View {
        if selectedType == .coInsured && !Dependencies.featureFlags().isEditCoInsuredEnabled {
            hSection {
                InfoCard(
                    text: L10n.InsurancesTab.contactUsToEditCoInsured,
                    type: .info
                )
            }
            .transition(.opacity)
            .sectionContainerStyle(.transparent)
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.Opaque.primary
        } else {
            hSurfaceColor.Opaque.primary
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.Opaque.primary
        } else {
            hBorderColor.secondary
        }
    }
}

struct EditContract_Previews: PreviewProvider {
    static var previews: some View {
        EditContract(id: "id")
    }
}
