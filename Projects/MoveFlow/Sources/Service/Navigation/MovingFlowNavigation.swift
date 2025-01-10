import ChangeTier
import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

@MainActor
public class MovingFlowNavigationViewModel: ObservableObject {
    @Published var isAddExtraBuildingPresented: HouseInformationInputModel?
    @Published public var document: hPDFDocument? = nil

    @Published public var addressInputModel = AddressInputModel()
    @Published public var movingFlowVm: MovingFlowModel?
    @Published public var houseInformationInputvm = HouseInformationInputModel()
    var movingFlowConfirmViewModel: MovingFlowConfirmViewModel?
    var quoteSummaryViewModel: QuoteSummaryViewModel?

    init() {}

    func getMovingFlowSummaryViewModel(
        using movingFlowConfirmVm: MovingFlowConfirmViewModel,
        router: Router
    ) -> QuoteSummaryViewModel? {
        if let movingFlowModel = movingFlowVm {
            let movingFlowQuotes = getQuotes(from: movingFlowModel)
            var contractInfos =
                movingFlowQuotes
                .map({ quote in
                    QuoteSummaryViewModel.ContractInfo(
                        id: quote.id,
                        displayName: quote.displayName,
                        exposureName: quote.exposureName ?? "",
                        newPremium: quote.premium,
                        currentPremium: quote.premium,
                        documents: quote.documents.map({
                            .init(displayName: $0.displayName, url: $0.url, type: .unknown)
                        }),
                        onDocumentTap: { document in
                            self.document = document
                        },
                        displayItems: quote.displayItems.map({ .init(title: $0.displayTitle, value: $0.displayValue) }
                        ),
                        insuranceLimits: quote.insurableLimits,
                        typeOfContract: quote.contractType
                    )
                })

            let _ =
                movingFlowQuotes
                .forEach({ quote in
                    quote.addons.forEach({ addonQuote in
                        let addonQuoteContractInfo = QuoteSummaryViewModel.ContractInfo(
                            id: addonQuote.id,
                            displayName: addonQuote.quoteInfo.title ?? "",
                            exposureName: L10n.addonFlowSummaryActiveFrom(
                                addonQuote.startDate.displayDateDDMMMYYYYFormat
                            ),
                            newPremium: addonQuote.price,
                            currentPremium: nil,
                            documents: addonQuote.addonVariant.documents,
                            onDocumentTap: { document in
                                self.document = document
                            },
                            displayItems: addonQuote.displayItems.map({
                                .init(title: $0.displayTitle, value: $0.displayValue)
                            }),
                            insuranceLimits: addonQuote.addonVariant.insurableLimits,
                            typeOfContract: nil,
                            removeModel: .init(
                                id: addonQuote.id,
                                title: "Remove Travel Insurance Plus",
                                description:
                                    "By removing this extended coverage, your insurance will no longer include extra protection while traveling.",
                                confirmButtonTitle: "Remove Travel Insurance Plus",
                                cancelRemovalButtonTitle: "Keep current coverage"
                            )
                        )
                        contractInfos.append(addonQuoteContractInfo)
                    })
                })

            let vm = QuoteSummaryViewModel(
                contract: contractInfos,
                //                total: movingFlowModel.total,
                onConfirmClick: {
                    Task {
                        await movingFlowConfirmVm.confirmMoveIntent(
                            intentId: self.movingFlowVm?.id ?? "",
                            homeQuoteId: self.movingFlowVm?.homeQuote?.id ?? ""
                        )
                    }
                    router.push(MovingFlowRouterWithHiddenBackButtonActions.processing)
                }
            )
            self.quoteSummaryViewModel = vm
            return vm
        }
        return nil
    }

    private func getQuotes(from data: MovingFlowModel) -> [MovingFlowQuote] {
        var allQuotes = data.quotes
        if let homeQuote = data.homeQuote {
            allQuotes.insert(homeQuote, at: 0)
        }
        return allQuotes
    }
}

enum MovingFlowRouterWithHiddenBackButtonActions: Hashable {
    case processing
}

extension MovingFlowRouterWithHiddenBackButtonActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .processing:
            return .init(describing: MovingFlowProcessingScreen.self)
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
            return .init(describing: MovingFlowConfirmScreen.self)
        case .houseFill:
            return .init(describing: MovingFlowHouseScreen.self)
        case .selectTier:
            return .init(describing: ChangeTierLandingScreen.self)
        }
    }

}

struct ExtraBuildingTypeNavigationModel: Identifiable, Equatable {
    static func == (lhs: ExtraBuildingTypeNavigationModel, rhs: ExtraBuildingTypeNavigationModel) -> Bool {
        return true
    }

    public var id: String?
    var extraBuildingType: ExtraBuildingType?

    var addExtraBuildingVm: MovingFlowAddExtraBuildingViewModel
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
                        openProcessingView(confirmVm: movingFlowNavigationVm.movingFlowConfirmViewModel!)
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
        .detent(
            item: $movingFlowNavigationVm.isAddExtraBuildingPresented,
            style: [.height]
        ) { houseInformationInputModel in
            MovingFlowAddExtraBuildingScreen(
                isBuildingTypePickerPresented: $isBuildingTypePickerPresented,
                houseInformationInputVm: houseInformationInputModel
            )
            .detent(item: $isBuildingTypePickerPresented, style: [.height]) { model in
                openTypeOfBuildingPicker(
                    for: model.extraBuildingType,
                    addExtraBuilingViewModel: model.addExtraBuildingVm
                )
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
        MovingFlowHousingTypeScreen(movingFlowNavigationVm: movingFlowNavigationVm)
            .withAlertDismiss()
    }

    func openApartmentFillScreen() -> some View {
        return MovingFlowAddressScreen(vm: movingFlowNavigationVm.addressInputModel)
            .withAlertDismiss()
    }

    func openHouseFillScreen() -> some View {
        return MovingFlowHouseScreen(houseInformationInputvm: movingFlowNavigationVm.houseInformationInputvm)
            .withAlertDismiss()
    }

    func openConfirmScreen() -> some View {
        movingFlowNavigationVm.movingFlowConfirmViewModel = .init()
        let model = movingFlowNavigationVm.getMovingFlowSummaryViewModel(
            using: movingFlowNavigationVm.movingFlowConfirmViewModel!,
            router: router
        )!
        return MovingFlowConfirmScreen(quoteSummaryViewModel: model)
            .navigationTitle(L10n.changeAddressSummaryTitle)
            .withAlertDismiss()
    }

    func openProcessingView(confirmVm: MovingFlowConfirmViewModel) -> some View {
        MovingFlowProcessingScreen(
            onSuccessButtonAction: {
                router.dismiss()
            },
            onErrorButtonAction: {
                router.pop()
            },
            movingFlowConfirmVm: confirmVm
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

    func openTypeOfBuildingPicker(
        for currentlySelected: ExtraBuildingType?,
        addExtraBuilingViewModel: MovingFlowAddExtraBuildingViewModel
    ) -> some View {
        TypeOfBuildingPickerScreen(
            currentlySelected: currentlySelected,
            isBuildingTypePickerPresented: $isBuildingTypePickerPresented,
            addExtraBuidlingViewModel: addExtraBuilingViewModel
        )
        .navigationTitle(L10n.changeAddressExtraBuildingContainerTitle)
        .embededInNavigation(
            options: [.navigationType(type: .large)],
            tracking: MovingFlowDetentType.typeOfBuildingPicker
        )
        .environmentObject(movingFlowNavigationVm)
    }
}

private enum MovingFlowDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .selectHousingType:
            return .init(describing: MovingFlowHousingTypeScreen.self)
        case .addExtraBuilding:
            return .init(describing: MovingFlowAddExtraBuildingScreen.self)
        case .typeOfBuildingPicker:
            return .init(describing: TypeOfBuildingPickerScreen.self)
        }
    }

    case selectHousingType
    case addExtraBuilding
    case typeOfBuildingPicker

}
