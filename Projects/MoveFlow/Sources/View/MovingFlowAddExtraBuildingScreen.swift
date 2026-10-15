import Combine
import SwiftUI
import hCore
import hCoreUI

struct MovingFlowAddExtraBuildingScreen: View {
    @State var vm = MovingFlowAddExtraBuildingViewModel()
    let houseInformationInputVm: HouseInformationInputModel

    @Environment(MovingFlowNavigationViewModel.self) var movingFlowNavigationVm

    init(
        houseInformationInputVm: HouseInformationInputModel
    ) {
        self.houseInformationInputVm = houseInformationInputVm
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
                        hSaveButton {
                            withAnimation {
                                addExtraBuilding()
                            }
                        }
                        hCancelButton {
                            movingFlowNavigationVm.isAddExtraBuildingPresented = nil
                        }
                    }
                    .padding(.vertical, .padding16)
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hFormContentPosition(.compact)
    }

    @ViewBuilder
    private var typeOfBuilding: some View {
        hFloatingField(
            value: vm.buildingType?.displayName ?? "",
            placeholder: L10n.changeAddressExtraBuildingContainerTitle,
            error: $vm.buildingTypeError
        ) {
            movingFlowNavigationVm.isBuildingTypePickerPresented = ExtraBuildingTypeNavigationModel(
                extraBuildingType: vm.buildingType,
                addExtraBuildingVm: vm
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

    @ViewBuilder
    private var connectedToWater: some View {
        CheckboxToggleView(
            title: L10n.changeAddressExtraBuildingsWaterInputLabel,
            isOn: $vm.connectedToWater.animation(.default)
        )
        .onTapGesture {
            withAnimation {
                vm.connectedToWater.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
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
        AddExtraBuildingType.livingArea
    }

    var next: AddExtraBuildingType? {
        nil
    }

    case livingArea
}

@Observable
public class MovingFlowAddExtraBuildingViewModel {
    var type: AddExtraBuildingType?

    var buildingType: ExtraBuildingType?
    var livingArea: String = ""
    var connectedToWater = false
    var livingAreaError: String?
    var buildingTypeError: String?

    func isValid() -> Bool {
        livingAreaError = (Int(livingArea) ?? 0) > 0 ? nil : L10n.changeAddressExtraBuildingSizeError
        buildingTypeError = buildingType == nil ? L10n.changeAddressExtraBuildingTypeError : nil
        return livingAreaError == nil && buildingTypeError == nil
    }
}

#Preview {
    MovingFlowAddExtraBuildingScreen(
        houseInformationInputVm: .init()
    )
}
