import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct EditContract: View {
    @PresentableStore var store: ContractStore
    @State var selectedType: EditType?
    @State var editTypes: [EditType] = []
    private let contract: Contract?
    init(id: String) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        contract = store.state.contractForId(id)
        if let contract {
            _editTypes = State(initialValue: EditType.getTypes(for: contract))
        } else {
            _editTypes = State(initialValue: [])
        }
    }
    var body: some View {
        hForm {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    ForEach(editTypes, id: \.rawValue) { editType in
                        hSection {
                            hRow {
                                HStack(spacing: 0) {
                                    hText(editType.title, style: .title3)
                                        .foregroundColor(hTextColor.primary)
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
                            store.send(.dismissEditInfo(type: selectedType))
                            switch selectedType {
                            case .coInsured:
                                if hAnalyticsExperiment.editCoinsured {
                                    if let contract {
                                        store.send(
                                            .openEditCoInsured(
                                                config: .init(contract: contract),
                                                fromInfoCard: false
                                            )
                                        )
                                    }
                                } else {
                                    store.send(.goToFreeTextChat)
                                }
                            case .changeAddress:
                                store.send(.goToMovingFlow)
                            case nil:
                                break
                            }
                        } content: {
                            hText(selectedType?.buttonTitle ?? "", style: .standard)
                        }
                        .disabled(selectedType == nil)
                        
                        
                        hButton.LargeButton(type: .ghost) {
                            store.send(.dismissEditInfo(type: nil))
                        } content: {
                           hText(L10n.generalCancelButton)
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.bottom, 16)
            }
        }
        .hDisableScroll
    }

    @ViewBuilder
    var infoView: some View {
        if selectedType == .coInsured && !hAnalyticsExperiment.editCoinsured {
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
            hTextColor.primary
        } else {
            hFillColor.opaqueOne
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.primary
        } else {
            hBorderColor.opaqueTwo
        }
    }
}

struct EditContract_Previews: PreviewProvider {
    static var previews: some View {
        EditContract(id: "id")
    }
}
