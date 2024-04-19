import Chat
import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ExtraBuildingTypeNavigationModel: Identifiable, Equatable {
    public var id: String?
    var extraBuildingType: ExtraBuildingType?
}

public class MovingFlowNavigationViewModel: ObservableObject {
    public init() {}

    @Published public var isChatPresented = false
    @Published var isAddExtraBuildingPresented = false
}

enum MovingFlowRouterActions {
    case confirm
    case houseFill
    case processing
}

public struct MovingFlowNavigation: View {
    @StateObject private var movingFlowVm = MovingFlowNavigationViewModel()
    @StateObject var router = Router()
    @State var cancellable: AnyCancellable?
    @Binding var isFlowPresented: Bool
    @State var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?

    public init(
        isFlowPresented: Binding<Bool>
    ) {
        self._isFlowPresented = isFlowPresented
    }

    public var body: some View {
        RouterHost(router: router) {
            openSelectHousingScreen()
                .routerDestination(for: HousingType.self) { housingType in
                    openApartmentFillScreen()
                }
                .routerDestination(for: MovingFlowRouterActions.self) { action in
                    switch action {
                    case .confirm:
                        openConfirmScreen()
                    case .houseFill:
                        openHouseFillScreen()
                    case .processing:
                        openProcessingView()  //hide back button
                    }
                }
        }
        .environmentObject(movingFlowVm)
        .onAppear {
            let store: MoveFlowStore = globalPresentableStoreContainer.get()
            cancellable = store.actionSignal.publisher.sink { _ in
            } receiveValue: { action in
                switch action {
                case let .navigation(navigationAction):
                    switch navigationAction {
                    case .openConfirmScreen:
                        router.push(MovingFlowRouterActions.confirm)
                    case .openHouseFillScreen:
                        router.push(MovingFlowRouterActions.houseFill)
                    case .openProcessingView:
                        router.push(MovingFlowRouterActions.processing)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        .detent(presented: $movingFlowVm.isAddExtraBuildingPresented, style: .height) {
            MovingFlowAddExtraBuildingView(isBuildingTypePickerPresented: $isBuildingTypePickerPresented)
                .detent(item: $isBuildingTypePickerPresented, style: .height) { extraBuildingType in
                    openTypeOfBuildingPicker(for: extraBuildingType.extraBuildingType)
                    // title: L10n.changeAddressExtraBuildingContainerTitle
                }
                .environmentObject(movingFlowVm)
        }

        .fullScreenCover(
            isPresented: $movingFlowVm.isChatPresented
        ) {
            ChatScreen(vm: .init(topicType: nil))
        }

    }

    func openSelectHousingScreen() -> some View {
        MovingFlowHousingTypeView()
    }

    func openApartmentFillScreen() -> some View {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        return MovingFlowAddressView(vm: store.addressInputModel)
    }

    func openHouseFillScreen() -> some View {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        return MovingFlowHouseView(vm: store.houseInformationInputModel)
    }

    func openConfirmScreen() -> some View {
        MovingFlowConfirm()
    }

    func openProcessingView() -> some View {
        MovingFlowProcessingView(onSuccessButtonAction: {
            isFlowPresented = false
        })
    }

    func openTypeOfBuildingPicker(for currentlySelected: ExtraBuildingType?) -> some View {
        CheckboxPickerScreen<ExtraBuildingType>(
            items: {
                let store: MoveFlowStore = globalPresentableStoreContainer.get()
                return store.state.movingFlowModel?.extraBuildingTypes
                    .compactMap({ (object: $0, displayName: .init(title: $0.translatedValue)) }) ?? []
            }(),
            preSelectedItems: {
                if let currentlySelected {
                    return [currentlySelected]
                }
                return []
            },
            onSelected: { selected in
                let store: MoveFlowStore = globalPresentableStoreContainer.get()
                if let selected = selected.first {
                    //                    store.send(.navigation(action: .dismissTypeOfBuilding))
                    isBuildingTypePickerPresented = nil
                    if let object = selected.0 {
                        store.send(.setExtraBuildingType(with: object))
                    }
                }
            },
            onCancel: {
                isBuildingTypePickerPresented = nil
            },
            singleSelect: true
        )
    }
}

//public struct MovingFlowJourneyNew {
//    @JourneyBuilder
//    static func getMovingFlowScreen(for action: MoveFlowAction) -> some JourneyPresentation {
//        if case let .navigation(navigationAction) = action {
//            if case .openAddressFillScreen = navigationAction {
//                MovingFlowJourneyNew.openApartmentFillScreen()
//            } else if case .openHouseFillScreen = navigationAction {
//                MovingFlowJourneyNew.openHouseFillScreen()
//            } else if case .openAddBuilding = navigationAction {
//                MovingFlowJourneyNew.openAddExtraBuilding()
//            } else if case .openConfirmScreen = navigationAction {
//                MovingFlowJourneyNew.openConfirmScreen()
//            } else if case .openProcessingView = navigationAction {
//                MovingFlowJourneyNew.openProcessingView()
//            } else if case .dismissMovingFlow = navigationAction {
//                DismissJourney()
//            } else if case .goBack = navigationAction {
//                PopJourney()
//            }
//        }
//    }
//
//public enum MovingFlowRedirectType {
//    case chat
//}
