import Presentation
import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleScreen: View {
    @PresentableStore var store: ContractStore

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
                    hSection {
                        ForEach(state.coInsured, id: \.self) { coInsured in
                            existingCoInsuredField(coInsured: coInsured)
                        }
                    }
                    .sectionContainerStyle(.transparent)

                    hSection {
                        ForEach(state.localCoInsured, id: \.self) { coInsured in
                            localInsuredField(coInsured: coInsured)
                        }
                    }
                    .sectionContainerStyle(.transparent)

                    hSection {
                        hButton.LargeButton(type: .secondary) {
                            store.send(
                                .coInsuredNavigationAction(
                                    action: .openCoInsuredInput(
                                        isDeletion: false,
                                        name: nil,
                                        personalNumber: nil,
                                        title: L10n.contractAddCoinsured
                                    )
                                )
                            )
                        } content: {
                            hText(L10n.contractAddCoinsured)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        state
                    }
                ) { state in
                    if state.localCoInsured.count > 0 {
                        confirmChangesView
                    }
                }
                cancelButton
            }
            .padding(.horizontal, 16)
        }
    }

    var cancelButton: some View {
        hButton.LargeButton(type: .ghost) {
            store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
        } content: {
            hText(L10n.generalCancelButton)
        }
        .padding(.horizontal, 16)
    }

    var confirmChangesView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 2) {
                HStack(spacing: 8) {
                    hText("Total")
                    Spacer()

                    if #available(iOS 16.0, *) {
                        hText("129 kr/mån")
                            .strikethrough()
                            .foregroundColor(hTextColor.secondary)
                    } else {
                        hText("129 kr/mån")
                            .foregroundColor(hTextColor.secondary)

                    }
                    hText("159 kr/mån")
                }
                hText("Starts from 16 nov 2023", style: .footnote)
                    .foregroundColor(hTextColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            hButton.LargeButton(type: .primary) {
                store.send(.applyLocalCoInsured)
                store.send(.coInsuredNavigationAction(action: .openCoInsuredProcessScreen))
            } content: {
                hText("Confirm changes")
            }
        }
    }

    @ViewBuilder
    func existingCoInsuredField(coInsured: CoInsuredModel) -> some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state
            }
        ) { state in
            let index = state.localCoInsured.firstIndex(where: { $0.name == coInsured.name && $0.SSN == coInsured.SSN })
            if index != nil {
                EmptyView()
            } else {

                HStack {
                    VStack(alignment: .leading) {
                        hText(coInsured.name)
                        hText(coInsured.SSN)
                            .foregroundColor(hTextColor.secondary)
                    }
                    Spacer()
                    Image(uiImage: hCoreUIAssets.closeSmall.image)
                        .foregroundColor(hTextColor.secondary)
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
                .padding(.vertical, 16)
                Divider()
            }
        }
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
                    Image(uiImage: hCoreUIAssets.closeSmall.image)
                        .foregroundColor(hTextColor.secondary)
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
            .padding(.top, 16)
        }
        statusPill(coInsured: coInsured)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 16)
        Divider()
    }

    @ViewBuilder
    func statusPill(coInsured: CoInsuredModel) -> some View {
        VStack {
            switch coInsured.type {
            case .added:
                hText("Activates 16 nov 2023", style: .standardSmall)
            case .deleted:
                hText("Active until 16 nov 2023", style: .standardSmall)
            case .none:
                EmptyView()
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .foregroundColor(pillTextdColor(coInsured: coInsured))
        .background(pillBackgroundColor(coInsured: coInsured))
        .cornerRadius(8)
    }

    @hColorBuilder
    func pillBackgroundColor(coInsured: CoInsuredModel) -> some hColor {
        switch coInsured.type {
        case .added:
            hSignalColor.amberFill
        case .deleted:
            hSignalColor.redFill
        case .none:
            hBackgroundColor.clear
        }
    }

    @hColorBuilder
    func pillTextdColor(coInsured: CoInsuredModel) -> some hColor {
        switch coInsured.type {
        case .added:
            hSignalColor.amberText
        case .deleted:
            hSignalColor.redText
        case .none:
            hBackgroundColor.clear
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
            Divider()
        }
        .sectionContainerStyle(.transparent)
    }
}

struct InsuredPeopleScreen_Previews: PreviewProvider {
    static var previews: some View {
        InsuredPeopleScreen()
    }
}
