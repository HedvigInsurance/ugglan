import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowHouseView: View {
    @StateObject var vm: HouseInformationInputModel

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
                    .disableOn(MoveFlowStore.self, [.requestMoveIntent])
                    hSection {
                        InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                    }
                    hSection {
                        hButton.LargeButton(type: .primary) {
                            vm.continuePressed()
                        } content: {
                            hText(L10n.General.submit, style: .body)
                        }
                        .trackLoading(MoveFlowStore.self, action: .requestMoveIntent)
                    }

                }
            }
            .padding(.bottom, 8)
            .padding(.top, 16)

        }
        .hFormTitle(.standard, .title1, L10n.changeAddressInformationAboutYourHouse)
        .sectionContainerStyle(.transparent)
        .retryView(MoveFlowStore.self, forAction: .requestMoveIntent, binding: $vm.error)
        .presentableStoreLensAnimation(.default)
        .onDisappear {
            vm.clearErrors()
        }
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
            hCounterField(
                value: $vm.bathrooms,
                placeholder: L10n.changeAddressBathroomsLabel,
                minValue: 1,
                maxValue: 10,
                error: $vm.bathroomsError
            ) { value in
                vm.type = nil
                if value == 0 {
                    return nil
                } else {
                    return "\(value)"
                }
            }
        }
        .sectionContainerStyle(.transparent)

    }

    private var extraBuildingTypes: some View {
        hSection {
            VStack(alignment: .leading, spacing: 0) {
                hText(L10n.changeAddressExtraBuildingsLabel, style: .standardSmall)

                ForEach(Array(vm.extraBuildings.enumerated()), id: \.element.id) { offset, extraBuilding in
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
                            withAnimation {
                                vm.remove(extraBuilding: extraBuilding)
                            }
                        } label: {
                            Image(uiImage: hCoreUIAssets.closeSmall.image)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(hTextColorNew.primary)
                        }
                    }
                    .padding(.vertical, 13)
                    if offset + 1 < vm.extraBuildings.count {
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

    private var isSubleted: some View {
        hSection {
            Toggle(isOn: $vm.isSubleted.animation(.default)) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.changeAddressSubletLabel, style: .standardLarge)
                }
            }
            .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    vm.type = nil
                    vm.isSubleted.toggle()
                }
            }
            .padding(.vertical, 21)
            .padding(.horizontal, 16)
        }
        .sectionContainerStyle(.opaque)
    }
}

struct MovingFlowHouseView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .nb_NO
        return MovingFlowHouseView(vm: HouseInformationInputModel())
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

public typealias ExtraBuildingType = String
class HouseInformationInputModel: ObservableObject {
    @Published var type: MovingFlowHouseFieldType?
    @Published var yearOfConstruction: String = ""
    @Published var ancillaryArea: String = ""
    @Published var bathrooms: Int = 1
    @Published var isSubleted = false
    @Published var yearOfConstructionError: String?
    @Published var ancillaryAreaError: String?
    @Published var bathroomsError: String?
    @Published var extraBuildings: [ExtraBuilding] = []

    @PresentableStore var store: MoveFlowStore
    @Published var error: String?
    init() {}

    func continuePressed() {
        if isInputValid() {
            store.send(.requestMoveIntent)
        }
    }

    private func isInputValid() -> Bool {
        func validate() -> Bool {
            withAnimation {
                yearOfConstructionError = !yearOfConstruction.isEmpty ? nil : L10n.changeAddressYearOfConstructionError
                ancillaryAreaError = !ancillaryArea.isEmpty ? nil : L10n.changeAddressAncillaryAreaError
                bathroomsError = bathrooms == 0 ? L10n.changeAddressBathroomsError : nil
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

    func remove(extraBuilding: ExtraBuilding) {
        UIApplication.dismissKeyboard()
        extraBuildings.removeAll(where: { $0.id == extraBuilding.id })
    }

    func clearErrors() {
        error = nil
        yearOfConstructionError = nil
        ancillaryAreaError = nil
        bathroomsError = nil
    }
}

struct ExtraBuilding: Identifiable {
    let id: String
    let type: ExtraBuildingType
    let livingArea: Int
    let connectedToWater: Bool

    var descriptionText: String {
        var elements: [String] = []
        elements.append("\(self.livingArea) \(L10n.changeAddressSizeSuffix)")
        if connectedToWater {
            elements.append(L10n.changeAddressExtraBuildingsWaterLabel)
        }
        return elements.joined(separator: " ∙ ")
    }
}

extension ExtraBuildingType {
    var translatedValue: String {
        let key = "FIELD_EXTRA_BUIDLINGS_\(self.uppercased())_LABEL"
        let translatedValue = L10nDerivation.init(table: "", key: key, args: []).render()
        return key == translatedValue ? self : translatedValue
    }
}
