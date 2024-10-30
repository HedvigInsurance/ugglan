import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowAddExtraBuildingView: View {
    @ObservedObject var vm: MovingFlowAddExtraBuildingViewModel
    @ObservedObject var houseInformationInputVm: HouseInformationInputModel

    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @Binding var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?

    init(
        isBuildingTypePickerPresented: Binding<ExtraBuildingTypeNavigationModel?>,
        vm: MovingFlowAddExtraBuildingViewModel,
        houseInformationInputVm: HouseInformationInputModel
    ) {
        self._isBuildingTypePickerPresented = isBuildingTypePickerPresented
        self.vm = vm
        self.houseInformationInputVm = houseInformationInputVm
        vm.clean()
    }

    var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    typeOfBuilding
                }
                .sectionContainerStyle(.transparent)
                hSection {
                    livingArea
                }
                .sectionContainerStyle(.transparent)
                connectedToWater
                hSection {
                    VStack {
                        hButton.LargeButton(type: .primary) {
                            withAnimation {
                                addExtraBuilding()
                            }
                        } content: {
                            hText(L10n.generalSaveButton)
                        }
                        hButton.LargeButton(type: .ghost) {
                            movingFlowNavigationVm.isAddExtraBuildingPresented = nil
                        } content: {
                            hText(L10n.generalCancelButton)
                        }

                    }
                    .padding(.vertical, .padding16)
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hDisableScroll
    }
    @ViewBuilder
    private var typeOfBuilding: some View {
        hFloatingField(
            value: vm.buildingType?.translatedValue ?? "",
            placeholder: L10n.changeAddressExtraBuildingContainerTitle,
            error: $vm.buildingTypeError
        ) {
            isBuildingTypePickerPresented = ExtraBuildingTypeNavigationModel(
                extraBuildingType: vm.buildingType
            )
        }
    }

    private var livingArea: some View {
        hFloatingTextField(
            masking: .init(type: .digits),
            value: $vm.livingArea,
            equals: $vm.type,
            focusValue: .livingArea,
            placeholder: L10n.changeAddressExtraBuildingSizeLabel,
            suffix: "m\u{00B2}",
            error: $vm.livingAreaError
        )
    }

    private var connectedToWater: some View {
        CheckboxToggleView(
            title: L10n.changeAddressExtraBuildingsWaterInputLabel,
            isOn: $vm.connectedToWater.animation(.default)
        )
        .hFieldSize(.large)
        .onTapGesture {
            withAnimation {
                vm.connectedToWater.toggle()
            }
        }
    }

    func addExtraBuilding() {
        if vm.isValid() {
            houseInformationInputVm.extraBuildings
                .append(
                    ExtraBuilding(
                        id: UUID().uuidString,
                        type: vm.buildingType!,
                        livingArea: Int(vm.livingArea) ?? 0,
                        connectedToWater: vm.connectedToWater
                    )
                )
            movingFlowNavigationVm.isAddExtraBuildingPresented = nil
        }
    }
}

enum AddExtraBuildingType: hTextFieldFocusStateCompliant {
    static var last: AddExtraBuildingType {
        return AddExtraBuildingType.livingArea
    }

    var next: AddExtraBuildingType? {
        return nil
    }

    case livingArea

}

public class MovingFlowAddExtraBuildingViewModel: ObservableObject {
    @Published var type: AddExtraBuildingType?

    @Published var buildingType: ExtraBuildingType?
    @Published var livingArea: String = ""
    @Published var connectedToWater = false
    @Published var livingAreaError: String?
    @Published var buildingTypeError: String?

    func clean() {
        self.type = nil
        self.buildingType = nil
        self.livingArea = ""
        self.connectedToWater = false
        self.livingAreaError = nil
        self.buildingTypeError = nil
    }

    func isValid() -> Bool {
        livingAreaError = (Int(livingArea) ?? 0) > 0 ? nil : L10n.changeAddressExtraBuildingSizeError
        buildingTypeError = buildingType == nil ? L10n.changeAddressExtraBuildingTypeError : nil
        return livingAreaError == nil && buildingTypeError == nil
    }
}

struct MovingFlowAddExtraBuildingView_Previews: PreviewProvider {
    @State static var isOn: ExtraBuildingTypeNavigationModel? = .init()

    static var previews: some View {
        MovingFlowAddExtraBuildingView(
            isBuildingTypePickerPresented: $isOn,
            vm: .init(),
            houseInformationInputVm: .init()
        )
    }
}
