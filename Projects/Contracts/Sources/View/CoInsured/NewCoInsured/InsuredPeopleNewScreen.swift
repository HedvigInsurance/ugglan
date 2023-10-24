import Presentation
import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleNewScreen: View {
    @PresentableStore var store: ContractStore
    @State var contractNbOfCoinsured = 2 /* TODO: CHANGE WHEN WE HAVE REAL DATA */
    
    public init() {
        store.send(.resetLocalCoInsured)
    }
    
    var body: some View {
        hForm {
            VStack(spacing: 0) {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        state
                    }
                ) { state in
                    contractOwnerField(coInsured: state.coInsured)
                    
                    hSection(state.localCoInsured, id: \.self) { localCoInsured in
                        localInsuredField(coInsured: localCoInsured)
                    }
                    .sectionContainerStyle(.transparent)
                    
                    if state.localCoInsured.count < contractNbOfCoinsured {
                        emptyCoInsuredField(localCoInsured: state.localCoInsured)
                    } else {
                        hSection {
                            InfoCard(text: "Please take a moment to review your personal information before saving.", type: .attention)
                        }
                        .padding(.top, 16)
                    }
                }
            }
        }
        .hFormAttachToBottom {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state
                }
            ) { state in
                VStack(spacing: 8) {
                    if (state.localCoInsured.count >= contractNbOfCoinsured) {
                        hButton.LargeButton(type: .primary) {
                            store.send(.applyLocalCoInsured)
                            store.send(.coInsuredNavigationAction(action: .openCoInsuredProcessScreen(showSuccess: false)))
                        } content: {
                            hText(L10n.generalSaveChangesButton)
                        }
                        .disabled((state.coInsured.count + state.localCoInsured.count) < contractNbOfCoinsured)
                        .padding(.horizontal, 16)
                    }
                    
                    hButton.LargeButton(type: .ghost) {
                        store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    func contractOwnerField(coInsured: [CoInsuredModel]) -> some View {
        hSection {
            HStack {
                VStack(alignment: .leading) {
                    hText("Julia Andersson")
                    hText("19900101-1111")
                }
                .foregroundColor(hTextColor.tertiary)
                Spacer()
                HStack(alignment: .top) {
                    Image(uiImage: hCoreUIAssets.lockSmall.image)
                        .foregroundColor(hTextColor.tertiary)
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                }
            }
            .padding(.vertical, 16)
            hRowDivider()
        }
        .sectionContainerStyle(.transparent)
    }
    
    @ViewBuilder
    func localInsuredField(coInsured: CoInsuredModel) -> some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    hText(coInsured.name)
                    hText(coInsured.SSN)
                        .foregroundColor(hTextColor.secondary)
                }
                Spacer()
                HStack {
                    Spacer()
                    hText(L10n.Claims.Edit.Screen.title)
                        .onTapGesture {
                            store.send(
                                .coInsuredNavigationAction(
                                    action: .openCoInsuredInput(
                                        isDeletion: true,
                                        name: coInsured.name,
                                        personalNumber: coInsured.SSN,
                                        title: L10n.contractRemoveCoinsuredConfirmation
                                    )
                                )
                            )
                        }
                }
            }
            .padding(.vertical, 16)
        }
        Divider()
    }
    
    func emptyCoInsuredField(localCoInsured: [CoInsuredModel]) -> some View {
        hSection {
            let nbOfFields = contractNbOfCoinsured - localCoInsured.count
            ForEach((1...nbOfFields), id: \.self) { index in
                VStack {
                    HStack {
                        hText(L10n.contractCoinsured)
                        Spacer()
                        HStack {
                            hText(L10n.generalAddInfoButton)
                            Image(uiImage: hCoreUIAssets.plusSmall.image)
                        }
                        .onTapGesture {
                            store.send(
                                .coInsuredNavigationAction(action: .openCoInsuredInput(
                                    isDeletion: false,
                                    name: nil,
                                    personalNumber: nil,
                                    title: L10n.contractAddConisuredInfo
                                )
                                ))
                        }
                    }
                    hText(L10n.contractNoInformation)
                        .foregroundColor(hTextColor.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 16)
                hRowDivider()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct InsuredPeopleScreenNew_Previews: PreviewProvider {
    static var previews: some View {
        InsuredPeopleScreen()
    }
}
