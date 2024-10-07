import ChangeTier
import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public class MovingFlowNavigationViewModel: ObservableObject {
    public init() {}
    @Published var isAddExtraBuildingPresented = false
    @Published public var document: Document? = nil
}

enum MovingFlowRouterWithHiddenBackButtonActions {
    case processing
}

extension MovingFlowRouterWithHiddenBackButtonActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .processing:
            return .init(describing: MovingFlowProcessingView.self)
        }
    }

}

enum MovingFlowRouterActions: Hashable {
    case confirm
    case houseFill
    case selectTier(changeTierModel: ChangeTierIntentModel)
}

extension MovingFlowRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .confirm:
            return .init(describing: MovingFlowConfirm.self)
        case .houseFill:
            return .init(describing: MovingFlowHouseView.self)
        case .selectTier:
            return .init(describing: ChangeTierLandingScreen.self)
        }
    }

}

struct ExtraBuildingTypeNavigationModel: Identifiable, Equatable {
    public var id: String?
    var extraBuildingType: ExtraBuildingType?
}

public struct MovingFlowNavigation: View {
    @StateObject private var movingFlowVm = MovingFlowNavigationViewModel()
    @StateObject var router = Router()
    @State var cancellable: AnyCancellable?
    @State var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?

    public init() {}

    public var body: some View {
        RouterHost(router: router, tracking: MovingFlowDetentType.selectHousingType) {
            openSelectHousingScreen()
                .routerDestination(for: HousingType.self) { housingType in
                    openApartmentFillScreen()
                }
                .routerDestination(for: MovingFlowRouterWithHiddenBackButtonActions.self, options: .hidesBackButton) {
                    action in
                    switch action {
                    case .processing:
                        openProcessingView()
                    }
                }
                .routerDestination(for: MovingFlowRouterActions.self) { action in
                    switch action {
                    case .confirm:
                        openConfirmScreen()
                    case .houseFill:
                        openHouseFillScreen()
                    case let .selectTier(model):
                        openChangeTier(model: model)
                    }
                }
        }
        .environmentObject(movingFlowVm)
        .onAppear {
            let store: MoveFlowStore = globalPresentableStoreContainer.get()
            cancellable = store.actionSignal
                .receive(on: RunLoop.main)
                .sink { _ in
                } receiveValue: { action in
                    switch action {
                    case .navigation(.openConfirmScreen):
                        router.push(MovingFlowRouterActions.confirm)
                    case let .navigation(action: .openSelectTierScreen(changeTierModel)):
                        router.push(MovingFlowRouterActions.selectTier(changeTierModel: changeTierModel))
                    default:
                        break
                    }
                }
        }
        .detent(presented: $movingFlowVm.isAddExtraBuildingPresented, style: [.height]) {
            MovingFlowAddExtraBuildingView(isBuildingTypePickerPresented: $isBuildingTypePickerPresented)
                .detent(item: $isBuildingTypePickerPresented, style: [.height]) { extraBuildingType in
                    openTypeOfBuildingPicker(for: extraBuildingType.extraBuildingType)
                }
                .environmentObject(movingFlowVm)
                .navigationTitle(L10n.changeAddressAddBuilding)
                .embededInNavigation(
                    options: [.navigationType(type: .large)],
                    tracking: MovingFlowDetentType.addExtraBuilding
                )
        }
        .detent(
            item: $movingFlowVm.document,
            style: [.large]
        ) { document in
            PDFPreview(document: .init(url: document.url, title: document.title))
        }
    }

    func openSelectHousingScreen() -> some View {
        MovingFlowHousingTypeView()
            .withDismissButton()
    }

    func openApartmentFillScreen() -> some View {
        return MovingFlowAddressView().withDismissButton()
    }

    func openHouseFillScreen() -> some View {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        return MovingFlowHouseView(vm: store.houseInformationInputModel).withDismissButton()
    }

    func openConfirmScreen() -> some View {
        MovingFlowConfirm()
            .navigationTitle(L10n.changeAddressSummaryTitle)
            .withDismissButton()
    }

    func openProcessingView() -> some View {
        MovingFlowProcessingView(
            onSuccessButtonAction: {
                router.dismiss()
            },
            onErrorButtonAction: {
                router.pop()
            }
        )
    }

    func openChangeTier(model: ChangeTierIntentModel) -> some View {
        let model = ChangeTierInput.existingIntent(intent: model) { (tier, deducitlbe) in
            router.push(MovingFlowRouterActions.confirm)
        }
        return ChangeTierNavigation(input: model, router: router)
    }

    func openTypeOfBuildingPicker(for currentlySelected: ExtraBuildingType?) -> some View {
        TypeOfBuildingPickerView(
            currentlySelected: currentlySelected,
            isBuildingTypePickerPresented: $isBuildingTypePickerPresented
        )
        .navigationTitle(L10n.changeAddressExtraBuildingContainerTitle)
        .embededInNavigation(
            options: [.navigationType(type: .large)],
            tracking: MovingFlowDetentType.typeOfBuildingPicker
        )
    }
}

private enum MovingFlowDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .selectHousingType:
            return .init(describing: MovingFlowHousingTypeView.self)
        case .addExtraBuilding:
            return .init(describing: MovingFlowAddExtraBuildingView.self)
        case .typeOfBuildingPicker:
            return .init(describing: TypeOfBuildingPickerView.self)
        }
    }

    case selectHousingType
    case addExtraBuilding
    case typeOfBuildingPicker

}
