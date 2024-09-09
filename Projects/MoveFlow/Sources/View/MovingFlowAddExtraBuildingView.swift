import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowAddExtraBuildingView: View {
    @StateObject var vm = MovingFlowAddExtraBuildingViewModel()
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @Binding var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?

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
                            movingFlowNavigationVm.isAddExtraBuildingPresented = false
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
            vm.store.houseInformationInputModel.extraBuildings.append(
                ExtraBuilding(
                    id: UUID().uuidString,
                    type: vm.buildingType!,
                    livingArea: Int(vm.livingArea) ?? 0,
                    connectedToWater: vm.connectedToWater
                )
            )
            movingFlowNavigationVm.isAddExtraBuildingPresented = false
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

class MovingFlowAddExtraBuildingViewModel: ObservableObject {
    @PresentableStore var store: MoveFlowStore
    @Published var type: AddExtraBuildingType?

    @Published var buildingType: ExtraBuildingType?
    @Published var livingArea: String = ""
    @Published var connectedToWater = false

    @Published var livingAreaError: String?
    @Published var buildingTypeError: String?
    private var cancellables = Set<AnyCancellable>()

    init() {
        trackBuildingTypeAction()
    }

    func trackBuildingTypeAction() {
        store.actionSignal
            .receive(on: RunLoop.main)
            .sink { [weak self] action in
                if case let .setExtraBuildingType(type) = action {
                    self?.buildingType = type
                }
            }
            .store(in: &cancellables)
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
        MovingFlowAddExtraBuildingView(isBuildingTypePickerPresented: $isOn)
    }
}
