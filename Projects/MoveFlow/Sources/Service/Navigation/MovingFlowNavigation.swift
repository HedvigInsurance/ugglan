import ChangeTier
import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class MovingFlowNavigationViewModel: ObservableObject {
    @Published var isAddExtraBuildingPresented = false
    @Published public var document: hPDFDocument? = nil

    @Published public var addressInputModel: AddressInputModel?
    @Published public var movingFlowVm: MovingFlowModel?
    @Published public var houseInformationInputVm: HouseInformationInputModel?
    @Published public var movingFlowAddExtraBuildingVm: MovingFlowAddExtraBuildingViewModel?
    @Published public var movingFlowConfirmVm = MovingFlowConfirmViewModel()

    init() {}
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
    @StateObject private var movingFlowNavigationVm = MovingFlowNavigationViewModel()
    @StateObject var router = Router()
    private let onMoved: () -> Void
    @State var cancellable: AnyCancellable?
    @State var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?

    public init(
        onMoved: @escaping () -> Void
    ) {
        self.onMoved = onMoved
    }

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
        .environmentObject(movingFlowNavigationVm)
        .detent(presented: $movingFlowNavigationVm.isAddExtraBuildingPresented, style: [.height]) {
            MovingFlowAddExtraBuildingView(isBuildingTypePickerPresented: $isBuildingTypePickerPresented)
                .environmentObject(movingFlowNavigationVm.movingFlowAddExtraBuildingVm ?? .init())
                .detent(item: $isBuildingTypePickerPresented, style: [.height]) { extraBuildingType in
                    openTypeOfBuildingPicker(for: extraBuildingType.extraBuildingType)
                }
                .environmentObject(movingFlowNavigationVm)
                .navigationTitle(L10n.changeAddressAddBuilding)
                .embededInNavigation(
                    options: [.navigationType(type: .large)],
                    tracking: MovingFlowDetentType.addExtraBuilding
                )
        }
        .detent(
            item: $movingFlowNavigationVm.document,
            style: [.large]
        ) { document in
            PDFPreview(document: document)
        }
        .onDisappear {
            onMoved()
        }
    }

    func openSelectHousingScreen() -> some View {
        MovingFlowHousingTypeView(movingFlowNavigationVm: movingFlowNavigationVm)
            .withDismissButton()
    }

    func openApartmentFillScreen() -> some View {
        return MovingFlowAddressView(vm: movingFlowNavigationVm.addressInputModel ?? .init())
            .withDismissButton()
    }

    func openHouseFillScreen() -> some View {
        return MovingFlowHouseView(vm: movingFlowNavigationVm.houseInformationInputVm ?? .init())
            .withDismissButton()
    }

    func openConfirmScreen() -> some View {
        MovingFlowConfirm()
            .navigationTitle(L10n.changeAddressSummaryTitle)
            .withDismissButton()
            .environmentObject(movingFlowNavigationVm.movingFlowConfirmVm)
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
        let model = ChangeTierInput.existingIntent(intent: model) { (tier, deductible) in
            var movingFlowModel = movingFlowNavigationVm.movingFlowVm
            let id = deductible.id
            if let homeQuote = movingFlowNavigationVm.movingFlowVm?.potentialHomeQuotes.first(where: { $0.id == id }) {
                movingFlowModel?.homeQuote = homeQuote
            }
            if let movingFlowModel {
                movingFlowNavigationVm.movingFlowVm = movingFlowModel
            }
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
        .environmentObject(movingFlowNavigationVm)
        .environmentObject(movingFlowNavigationVm.movingFlowAddExtraBuildingVm ?? .init())
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
