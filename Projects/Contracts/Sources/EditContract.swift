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
    @State var vc: UIViewController?
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
                hSection {
                    VStack(spacing: 4) {
                        if selectedType != nil {
                            hButton.LargeButton(type: .primary) {
                                store.send(.dismissEditInfo(type: selectedType))
                                switch selectedType {
                                case .coInsured:
                                    store.send(
                                        .openEditCoInsured(
                                            contractId: contract?.id ?? "",
                                            fromInfoCard: false
                                        )
                                    )
                                case .changeAddress:
                                    store.send(.goToMovingFlow)
                                case nil:
                                    break
                                }
                            } content: {
                                hText(L10n.generalContinueButton, style: .standard)
                            }
                        }
                        hButton.LargeButton(type: .ghost) {
                            store.send(.dismissEditInfo(type: nil))
                        } content: {
                            hText(L10n.generalCancelButton, style: .standard)
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.bottom, 16)
            }
        }
        .hDisableScroll
        .introspectViewController { vc in
            weak var `vc` = vc
            if self.vc != vc {
                self.vc = vc
            }
        }
        .onChange(of: selectedType) { newValue in
            if #available(iOS 16.0, *) {
                for i in 1...3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 + Double(i) * 0.05) {
                        vc?.sheetPresentationController?.invalidateDetents()
                        vc?.sheetPresentationController?
                            .animateChanges {

                            }
                    }
                }
            }
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
