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
                hSection {
                    livingArea
                }
                hSection {
                    connectedToWater
                }
                hSection {
                    VStack {
                        hButton.LargeButton(type: .primary) {
                            vm.addExtraBuilding()
                        } content: {
                            hText(L10n.generalSaveButton)
                        }
                        hButton.LargeButton(type: .ghost) {

                        } content: {
                            hText(L10n.generalCancelButton)
                        }

                    }
                    .padding(.vertical, 16)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }
    @ViewBuilder
    private var typeOfBuilding: some View {
        hFloatingField(
            value: vm.buildingType?.translatedValue ?? "",
            placeholder: L10n.changeAddressExtraBuildingContainerTitle
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
            suffix: L10n.changeAddressSizeSuffix,
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
        store.send(.addExtraBuilding(with: self.asExtraBuilding()))
        L10n.changeAddressExtraBuildingSizeLabel
    }

    func showTypeOfBuilding() {
        store.send(.navigation(action: .openTypeOfBuilding(for: buildingType)))
    }

}

extension MovingFlowAddExtraBuildingViewModel {
    func asExtraBuilding() -> HouseInformationModel.ExtraBuilding {
        HouseInformationModel.ExtraBuilding(
            id: UUID().uuidString,
            type: buildingType ?? "",
            livingArea: Int(livingArea) ?? 0,
            connectedToWater: connectedToWater
        )
    }
}

struct MovingFlowAddExtraBuildingView_Previews: PreviewProvider {
    @PresentableStore static var store: MoveFlowStore
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        let fragment = OctopusGraphQL.MoveIntentFragment(
            currentHomeAddresses: [],
            extraBuildingTypes: OctopusGraphQL.MoveExtraBuildingType.allCases,
            id: "id",
            maxMovingDate: "",
            minMovingDate: "",
            suggestedNumberCoInsured: 2,
            quotes: []
        )
        let model = MovingFlowModel(from: fragment)
        store.send(.setMoveIntent(with: model))
        return MovingFlowAddExtraBuildingView()
    }
}
