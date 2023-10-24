import Presentation
import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleScreen: View {
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

                    if (state.coInsured.count + state.localCoInsured.count) < contractNbOfCoinsured {
                        emptyCoInsuredField(coInsured: state.coInsured)
                    }

                    if state.coInsured.count >= contractNbOfCoinsured {
                        hSection {
                            hButton.LargeButton(type: .secondary) {
                                store.send(
                                    .openCoInsuredInput(
                                        isDeletion: false,
                                        name: nil,
                                        personalNumber: nil,
                                        title: L10n.contractAddCoinsured
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
        }
        .hFormAttachToBottom {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state
                }
            ) { state in
                VStack(spacing: 8) {
                    if state.haveChangedCoInsured
                        && (state.localCoInsured.count + state.coInsured.count) >= contractNbOfCoinsured
                    {
                        hButton.LargeButton(type: .primary) {
                            store.send(.addCoInsured)
                        } content: {
                            hText(L10n.generalSaveChangesButton)
                        }
                        .disabled((state.coInsured.count + state.localCoInsured.count) < contractNbOfCoinsured)
                        .padding(.horizontal, 16)
                    }

                    hButton.LargeButton(type: .ghost) {
                        store.send(.dismissEditConInsureFlow)
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    @ViewBuilder
    func existingCoInsuredField(coInsured: CoInsuredModel) -> some View {
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
                        .openCoInsuredInput(
                            isDeletion: true,
                            name: coInsured.name,
                            personalNumber: coInsured.SSN,
                            title: L10n.contractRemoveCoinsuredConfirmation
                        )
                    )
                }
        }
        .padding(.vertical, 16)
        Divider()
    }

    @ViewBuilder
    func localInsuredField(coInsured: CoInsuredModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                hText(coInsured.name)
                hText(coInsured.SSN)
                    .foregroundColor(hTextColor.secondary)
            }
            Spacer()
            HStack {
                hText(L10n.Claims.Edit.Screen.title)
                    .onTapGesture {
                        store.send(
                            .openCoInsuredInput(
                                isDeletion: false,
                                name: coInsured.name,
                                personalNumber: coInsured.SSN,
                                title: L10n.contractAddConisuredInfo
                            )
                        )
                    }
            }
        }
        .padding(.vertical, 16)
        Divider()
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

    func emptyCoInsuredField(coInsured: [CoInsuredModel]) -> some View {
        hSection {
            let nbOfFields = contractNbOfCoinsured - coInsured.count
            ForEach(0..<nbOfFields) { index in
                hRow {
                    VStack(alignment: .leading) {
                        hText(L10n.contractCoinsured)
                        hText(L10n.contractNoInformation)
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                .withCustomAccessory {
                    Spacer()
                    HStack(alignment: .top, spacing: 8) {
                        hText(L10n.generalAddInfoButton)
                        Image(uiImage: hCoreUIAssets.plusSmall.image)
                    }
                    .onTapGesture {
                        store.send(
                            .openCoInsuredInput(
                                isDeletion: false,
                                name: nil,
                                personalNumber: nil,
                                title: L10n.contractAddConisuredInfo
                            )
                        )
                    }
                }
                hRowDivider()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct InsuredPeopleScreen_Previews: PreviewProvider {
    static var previews: some View {
        InsuredPeopleScreen()
    }
}

extension InsuredPeopleScreen {
    public func journey<ResultJourney: JourneyPresentation>(
        style: PresentationStyle = .default,
        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney,
        options: PresentationOptions = [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleScreen()
        ) { action in
            if case let .openCoInsuredInput(isDeletion, name, personalNumber, title) = action {
                HostingJourney(
                    ContractStore.self,
                    rootView: CoInusuredInput(isDeletion: isDeletion, name: name, personalNumber: personalNumber),
                    style: .detented(.scrollViewContentSize),
                    options: [.largeNavigationBar, .blurredBackground]
                ) { action in
                    if case .dismissEdit = action {
                        PopJourney()
                    } else if case .dismissEditConInsureFlow = action {
                        DismissJourney()
                    } else if case .addLocalCoInsured = action {
                        PopJourney()
                    } else if case .removeLocalCoInsured = action {
                        PopJourney()
                    }
                }
                .configureTitle(title)
            }
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
    }
}
