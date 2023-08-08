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
                                        .foregroundColor(hTextColorNew.primary)
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
                                .padding(.vertical, 5)
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
                    infoView
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                }
                .sectionContainerStyle(.transparent)
            }

        }
        .hFormAttachToBottom {
            hSection {
                if selectedType != nil {
                    hButton.LargeButtonPrimary {
                        store.send(.dismissEditInfo(type: selectedType))
                        switch selectedType {
                        case .coInsured:
                            store.send(.goToFreeTextChat)
                        case .changeAddress:
                            store.send(.goToMovingFlow)
                        case nil:
                            break
                        }
                    } content: {
                        hText(selectedType?.buttonTitle ?? "", style: .standard)
                    }
                }
                hButton.LargeButtonText {
                    store.send(.dismissEditInfo(type: nil))
                } content: {
                    hText(L10n.generalCancelButton, style: .standard)
                }
            }
            .padding(.top, 16)
            .sectionContainerStyle(.transparent)
        }
        .introspectViewController { vc in
            weak var `vc` = vc
            if self.vc != vc {
                self.vc = vc
            }
        }
        .onChange(of: selectedType) { newValue in
            if #available(iOS 16.0, *) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    vc?.sheetPresentationController?
                        .animateChanges {
                            vc?.sheetPresentationController?.invalidateDetents()
                        }
                }
            }
        }

        //            CheckboxPickerScreen(
        //                items: EditType.getTypes(for: contract).compactMap({($0, $0.title)}),
        //                preSelectedItems: { [] },
        //                onChange: { value in
        //                    withAnimation {
        //                        selectedType = value.first
        //                    }
        //                },
        //                onSelected: { value in
        //                    if let selectedType = value.first {
        //                        let store: ContractStore = globalPresentableStoreContainer.get()
        //                        store.send(.dismissEditInfo(type: selectedType))
        //                        switch selectedType {
        //                        case .coInsured:
        //                            store.send(.goToFreeTextChat)
        //                        case .changeAddress:
        //                            store.send(.goToMovingFlow)
        //                        }
        //                    }
        //                },
        //                onCancel: {
        //                    let store: ContractStore = globalPresentableStoreContainer.get()
        //                    store.send(.dismissEditInfo(type: nil))
        //                },
        //                singleSelect: true
        //            ).hFormAttachToBottom {
        //                if case .coInsured = selectedType {
        //                    InfoCard(text: "You need to contact us in the chat to edit the amount of co-insured on your insurance", type: .info).transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
        //                }
        //            }.introspectViewController { vc in
        //                weak var `vc` = vc
        //                if self.vc != vc {
        //                    self.vc = vc
        //                }
        //            }.onChange(of: selectedType) { newValue in
        //                if #available(iOS 16.0, *) {
        //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        //                        vc?.sheetPresentationController?.animateChanges {
        //                            vc?.sheetPresentationController?.invalidateDetents()
        //                        }
        //                    }
        //                }
        //            }
    }

    @ViewBuilder
    var infoView: some View {
        if selectedType == .coInsured {
            InfoCard(
                text: "You need to contact us in the chat to edit the amount of co-insured on your insurance",
                type: .info
            )
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hFillColorNew.opaqueOne
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hBorderColorNew.opaqueTwo
        }
    }
}

struct EditContract_Previews: PreviewProvider {
    static var previews: some View {
        EditContract(id: "id")
    }
}
