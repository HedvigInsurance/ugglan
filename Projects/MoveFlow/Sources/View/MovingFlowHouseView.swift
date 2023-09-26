import Flow
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowHouseView: View {
    @StateObject var vm = MovingFlowHouseViewModel()

    var body: some View {
        hForm {
            VStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        yearOfConstructionField
                        ancillaryAreaField
                        bathroomsField
                        isSubleted
                        extraBuildingTypes
                    }
                    .trackLoading(MoveFlowStore.self, action: .requestMoveIntent)
                    hSection {
                        InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                    }
                    hSection {
                        LoadingButtonWithContent(
                            MoveFlowStore.self,
                            .requestMoveIntent
                        ) {
                            vm.continuePressed()
                        } content: {
                            hText(L10n.General.submit, style: .body)
                        }
                    }
                }
            }
            .padding(.bottom, 8)
            .padding(.top, 16)

        }
        .hFormTitle(.standard, .title1, L10n.changeAddressInformationAboutYourHouse)
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.bottom)
    }

    private var yearOfConstructionField: some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.yearOfConstruction,
                equals: $vm.type,
                focusValue: .yearOfConstruction,
                placeholder: L10n.changeAddressYearOfConstructionLabel,
                error: $vm.yearOfConstructionError
            )
        }
    }

    private var ancillaryAreaField: some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.ancillaryArea,
                equals: $vm.type,
                focusValue: .ancillaryArea,
                placeholder: L10n.changeAddressAncillaryAreaLabel,
                suffix: L10n.changeAddressSizeSuffix,
                error: $vm.ancillaryAreaError
            )
        }
    }

    private var bathroomsField: some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.bathrooms,
                equals: $vm.type,
                focusValue: .bathrooms,
                placeholder: L10n.changeAddressBathroomsLabel,
                error: $vm.bathroomsError
            )
        }
    }

    private var extraBuildingTypes: some View {
        PresentableStoreLens(
            MoveFlowStore.self,
            getter: { state in
                state.houseInformationModel.extraBuildings
            }
        ) { extraBuildings in
            hSection {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.changeAddressExtraBuildingsLabel, style: .standardSmall)

                    ForEach(Array(extraBuildings.enumerated()), id: \.element.id) { offset, extraBuilding in
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                hText(extraBuilding.type.translatedValue, style: .standard)
                                HStack(spacing: 0) {
                                    hText(extraBuilding.descriptionText, style: .standardSmall)
                                        .foregroundColor(hTextColorNew.secondary)
                                }
                            }
                            Spacer()
                            Button {
                                vm.remove(extraBuilding: extraBuilding)
                            } label: {
                                Image(uiImage: hCoreUIAssets.closeSmall.image)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(hTextColorNew.primary)
                            }
                        }
                        .padding(.vertical, 13)
                        if offset + 1 < extraBuildings.count {
                            Divider()
                        }
                    }
                    hButton.MediumButton(type: .primaryAlt) {
                        vm.addExtraBuilding()
                    } content: {
                        HStack {
                            Image(uiImage: hCoreUIAssets.plusSmall.image)
                                .resizable()
                                .frame(width: 16, height: 16)
                            hText(L10n.changeAddressAddBuilding)
                        }
                    }
                    .padding(.top, 8)

                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
            }
            .sectionContainerStyle(.opaque)
            .padding(.top, 6)

        }
    }

    private var isSubleted: some View {
        hSection {
            Toggle(isOn: $vm.isSubleted.animation(.default)) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.changeAddressSubletLabel, style: .standardLarge)
                }
            }
            .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
            .padding(.vertical, 21)
            .padding(.horizontal, 16)
        }
        .sectionContainerStyle(.opaque)
    }
}

struct MovingFlowHouseView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .nb_NO
        return MovingFlowHouseView()
    }
}

enum MovingFlowHouseFieldType: hTextFieldFocusStateCompliant {
    static var last: MovingFlowHouseFieldType {
        return MovingFlowHouseFieldType.bathrooms
    }

    var next: MovingFlowHouseFieldType? {
        switch self {
        case .yearOfConstruction:
            return .ancillaryArea
        case .ancillaryArea:
            return .bathrooms
        case .bathrooms:
            return nil
        }
    }

    case yearOfConstruction
    case ancillaryArea
    case bathrooms

}

class MovingFlowHouseViewModel: ObservableObject {
    @Published var type: MovingFlowHouseFieldType?
    @Published var yearOfConstruction: String = ""
    @Published var ancillaryArea: String = ""
    @Published var bathrooms: String = ""
    @Published var isSubleted = false
    @Published var yearOfConstructionError: String?
    @Published var ancillaryAreaError: String?
    @Published var bathroomsError: String?

    @PresentableStore var store: MoveFlowStore

    init() {}

    var disposeBag = DisposeBag()
    func continuePressed() {
        if isInputValid() {
            store.send(.setHouseInformation(with: self.toHouseInformationModel()))
        }
    }

    private func isInputValid() -> Bool {
        func validate() -> Bool {
            withAnimation {
                yearOfConstructionError = !yearOfConstruction.isEmpty ? nil : L10n.changeAddressYearOfConstructionError
                ancillaryAreaError = !ancillaryArea.isEmpty ? nil : L10n.changeAddressAncillaryAreaError
                bathroomsError = !bathrooms.isEmpty ? nil : L10n.changeAddressBathroomsError
                return yearOfConstructionError == nil && ancillaryAreaError == nil && bathroomsError == nil
            }
        }
        return validate()
    }

    func addExtraBuilding() {
        UIApplication.dismissKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.store.send(.navigation(action: .openAddBuilding))
        }
    }

    func remove(extraBuilding: HouseInformationModel.ExtraBuilding) {
        UIApplication.dismissKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.store.send(.removeExtraBuilding(with: extraBuilding))
        }
    }
}

extension MovingFlowHouseViewModel {
    func toHouseInformationModel() -> HouseInformationModel {
        HouseInformationModel(
            yearOfConstruction: Int(self.yearOfConstruction) ?? 0,
            ancillaryArea: Int(self.ancillaryArea) ?? 0,
            numberOfBathrooms: Int(self.bathrooms) ?? 0,
            isSubleted: isSubleted,
            extraBuildings: []
        )
    }
}
