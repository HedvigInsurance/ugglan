import Flow
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowAddExtraBuildingView: View {
    @StateObject var vm = MovingFlowAddExtraBuildingViewModel()
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
                hSection {
                    connectedToWater
                }
                hSection {
                    VStack {
                        hButton.LargeButton(type: .primary) {
                            withAnimation {
                                vm.addExtraBuilding()
                            }
                        } content: {
                            hText(L10n.generalSaveButton)
                        }
                        hButton.LargeButton(type: .ghost) {
                            vm.dissmisAddExtraBuilding()
                        } content: {
                            hText(L10n.generalCancelButton)
                        }

                    }
                    .padding(.vertical, 16)
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
            vm.showTypeOfBuilding()
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
        hSection {
            Toggle(isOn: $vm.connectedToWater.animation(.default)) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.changeAddressExtraBuildingsWaterInputLabel, style: .standardLarge)
                }
            }
            .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    vm.connectedToWater.toggle()
                }
            }
            .padding(.vertical, 21)
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

    init() {
        trackBuildingTypeAction()
    }

    func trackBuildingTypeAction() {
        disposeBag += store.actionSignal.onValue { [weak self] action in
            if case let .setExtraBuildingType(type) = action {
                self?.buildingType = type
            }
        }
    }
    var disposeBag = DisposeBag()
    func addExtraBuilding() {
        if isValid() {
            store.houseInformationInputModel.extraBuildings.append(
                ExtraBuilding(
                    id: UUID().uuidString,
                    type: buildingType!,
                    livingArea: Int(livingArea) ?? 0,
                    connectedToWater: connectedToWater
                )
            )
            store.send(.navigation(action: .dismissAddBuilding))
        }
    }

    func dissmisAddExtraBuilding() {
        store.send(.navigation(action: .dismissAddBuilding))
    }

    private func isValid() -> Bool {
        livingAreaError = (Int(livingArea) ?? 0) > 0 ? nil : L10n.changeAddressExtraBuildingSizeError
        buildingTypeError = buildingType == nil ? L10n.changeAddressExtraBuildingTypeError : nil
        return livingAreaError == nil && buildingTypeError == nil
    }

    func showTypeOfBuilding() {
        store.send(.navigation(action: .openTypeOfBuilding(for: buildingType)))
    }

}
