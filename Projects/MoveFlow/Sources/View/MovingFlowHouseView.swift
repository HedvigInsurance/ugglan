import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowHouseView: View {
    @ObservedObject var vm: HouseInformationInputModel
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel

    var body: some View {
        LoadingViewWithErrorState(
            MoveFlowStore.self,
            .requestMoveIntent
        ) {
            form
        } onError: { [weak vm] error in
            GenericErrorView(
                description: error
            )
            .hErrorViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        vm?.error = nil
                        let store: MoveFlowStore = globalPresentableStoreContainer.get()
                        store.removeLoading(for: .requestMoveIntent)
                    }),
                    dismissButton: nil
                )
            )
        }
        .onDisappear {
            vm.clearErrors()
        }
    }

    var form: some View {
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
                            hText(L10n.saveAndContinueButtonLabel, style: .body1)
                        }
                    }

                }
            }
            .padding(.bottom, .padding8)
            .padding(.top, .padding16)

        }
        .trackLoading(MoveFlowStore.self, action: .requestMoveIntent)
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.movingEmbarkTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .standard,
                .heading2,
                L10n.changeAddressInformationAboutYourHouse
            )
        )
        .sectionContainerStyle(.transparent)
        .presentableStoreLensAnimation(.default)
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
                suffix: "m\u{00B2}",
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
            hRow {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        hText(L10n.changeAddressExtraBuildingsLabel, style: .label)
                        Spacer()
                    }
                    ForEach(Array(vm.extraBuildings.enumerated()), id: \.element.id) { offset, extraBuilding in
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                hText(extraBuilding.type.translatedValue, style: .body1)
                                HStack(spacing: 0) {
                                    hText(extraBuilding.descriptionText, style: .label)
                                        .foregroundColor(hTextColor.Opaque.secondary)
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
                                    .foregroundColor(hTextColor.Opaque.primary)
                            }
                        }
                        .padding(.vertical, .padding12)
                        if offset + 1 < vm.extraBuildings.count {
                            Divider()
                        }
                    }
                    hButton.MediumButton(type: .primaryAlt) {
                        addExtraBuilding()
                    } content: {
                        HStack {
                            Image(uiImage: hCoreUIAssets.plusSmall.image)
                                .resizable()
                                .frame(width: .padding16, height: .padding16)
                            hText(L10n.changeAddressAddBuilding)
                        }
                    }
                    .hButtonDontShowLoadingWhenDisabled(true)
                    .disableOn(MoveFlowStore.self, [.requestMoveIntent])
                    .fixedSize(horizontal: true, vertical: false)
                    .hUseLightMode
                    .padding(.top, .padding8)

                }
            }
            .verticalPadding(0)
            .padding(.top, .padding12)
            .padding(.bottom, .padding16)
        }
        .sectionContainerStyle(.opaque)
        .padding(.top, .padding6)
    }

    private var isSubleted: some View {
        CheckboxToggleView(
            title: L10n.changeAddressSubletLabel,
            isOn: $vm.isSubleted.animation(.default)
        )
        .hFieldSize(.large)
        .onTapGesture {
            withAnimation {
                vm.type = nil
                vm.isSubleted.toggle()
            }
        }
    }

    func addExtraBuilding() {
        UIApplication.dismissKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            movingFlowNavigationVm.isAddExtraBuildingPresented = true
        }
    }
}

struct MovingFlowHouseView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.nb_NO)
        return MovingFlowHouseView(vm: HouseInformationInputModel())
    }
}

enum MovingFlowHouseFieldType: hTextFieldFocusStateCompliant {
    static var last: MovingFlowHouseFieldType {
        return MovingFlowHouseFieldType.ancillaryArea
    }

    var next: MovingFlowHouseFieldType? {
        switch self {
        case .yearOfConstruction:
            return .ancillaryArea
        case .ancillaryArea:
            return nil
        }
    }

    case yearOfConstruction
    case ancillaryArea
}

public typealias ExtraBuildingType = String
public class HouseInformationInputModel: ObservableObject {

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

    func remove(extraBuilding: ExtraBuilding) {
        UIApplication.dismissKeyboard()
        extraBuildings.removeAll(where: { $0.id == extraBuilding.id })
    }

    func clearErrors() {
        error = nil
        yearOfConstructionError = nil
        ancillaryAreaError = nil
        bathroomsError = nil
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        store.removeLoading(for: .requestMoveIntent)
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
