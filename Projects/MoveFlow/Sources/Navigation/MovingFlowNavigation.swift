import ChangeTier
import Combine
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class MovingFlowNavigationViewModel: ObservableObject, ChangeTierQuoteDataProvider {
    @Inject private var service: MoveFlowClient
    @Published var viewState: ProcessingState = .loading
    var errorTitle: String?
    @Published var isAddExtraBuildingPresented: HouseInformationInputModel?
    @Published var document: hPDFDocument? = nil
    @Published var moveConfigurationModel: MoveConfigurationModel?
    @Published var moveQuotesModel: MoveQuotesModel?
    @Published var addressInputModel = AddressInputModel()
    @Published var houseInformationInputvm = HouseInformationInputModel()
    @Published var selectedHomeQuote: MovingFlowQuote?
    @Published var selectedHomeAddress: MoveAddress?
    @Published var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?
    var totalPremium: Premium?
    var movingFlowConfirmViewModel: MovingFlowConfirmViewModel?
    var quoteSummaryViewModel: QuoteSummaryViewModel?
    var removedAddonIds: [String] = []

    fileprivate var initialTrackingType: MovingFlowDetentType?
    init() {
        initializeData()
    }

    private func initializeData() {
        Task {
            await getMoveIntent()
        }
    }

    @MainActor
    func getMoveIntent() async {
        withAnimation {
            self.viewState = .loading
            errorTitle = nil
        }

        do {
            let intentVm = try await service.sendMoveIntent()

            if intentVm.currentHomeAddresses.count == 1 {
                selectedHomeAddress = intentVm.currentHomeAddresses.first
            }
            addressInputModel.nbOfCoInsured = selectedHomeAddress?.suggestedNumberCoInsured ?? 0
            moveConfigurationModel = intentVm
            initialTrackingType = intentVm.currentHomeAddresses.count == 1 ? .selectHousingType : .selectContract
            withAnimation {
                self.viewState = .success
            }
        } catch {
            if let error = error as? MovingFlowError {
                errorTitle = error.title
                viewState = .error(errorMessage: error.localizedDescription)
            } else {
                viewState = .error(errorMessage: L10n.General.errorBody)
            }
        }
    }

    func setMovingFlowSummaryViewModel(router: Router) {
        let movingFlowQuotes = getQuotes()
        var contractInfos: [QuoteSummaryViewModel.ContractInfo] = []
        movingFlowConfirmViewModel = .init()
        for quote in movingFlowQuotes {
            var documents: [hPDFDocument] = quote.documents.map {
                .init(displayName: $0.displayName, url: $0.url, type: .unknown)
            }
            var displayItems: [QuoteDisplayItem] = []
            displayItems.append(.init(title: quote.displayName, value: quote.baseGrossPremium.formattedAmountPerMonth))
            for addon in quote.addons {
                if !removedAddonIds.contains(addon.id) {
                    documents.append(contentsOf: addon.addonVariant.documents)
                    displayItems.append(
                        .init(title: addon.addonVariant.displayName, value: addon.grossPremium.formattedAmountPerMonth)
                    )
                }
            }
            displayItems.append(
                contentsOf: quote.priceBreakdownItems.map { .init(title: $0.displayTitle, value: $0.displayValue) }
            )
            let contractQuote = QuoteSummaryViewModel.ContractInfo(
                id: quote.id,
                displayName: quote.displayName,
                exposureName: quote.exposureName ?? "",
                premium: quote.totalPremium,
                documentSection: .init(
                    documents: documents,
                    onTap: { [weak self] document in
                        self?.document = document
                    }
                ),
                displayItems: quote.displayItems.map({ .init(title: $0.displayTitle, value: $0.displayValue) }
                ),
                insuranceLimits: quote.insurableLimits,
                typeOfContract: quote.contractType,
                priceBreakdownItems: displayItems
            )
            contractInfos.append(contractQuote)
        }

        let vm = QuoteSummaryViewModel(
            contract: contractInfos,
            activationDate: movingFlowQuotes.first?.startDate,
            premium: totalPremium ?? .init(gross: nil, net: nil)
        )
        vm.onConfirmClick = { [weak router] in
            Task { [weak self] in
                guard let self = self,
                    let movingFlowConfirmViewModel = self.movingFlowConfirmViewModel
                else { return }
                await movingFlowConfirmViewModel.confirmMoveIntent(
                    intentId: self.moveConfigurationModel?.id ?? "",
                    currentHomeQuoteId: self.selectedHomeQuote?.id ?? "",
                    removedAddons: self.removedAddonIds
                )
            }
            router?.push(MovingFlowRouterWithHiddenBackButtonActions.processing)
        }
        quoteSummaryViewModel = vm
    }

    private func getQuotes() -> [MovingFlowQuote] {
        var allQuotes = moveQuotesModel?.mtaQuotes ?? []
        if let selectedHomeQuote = selectedHomeQuote {
            allQuotes.insert(selectedHomeQuote, at: 0)
        }
        return allQuotes
    }

    var movingDate: String {
        (selectedHomeQuote?.startDate ?? moveQuotesModel?.mtaQuotes.first?.startDate)?.displayDateDDMMMYYYYFormat ?? ""
    }

    public func getTotal(
        selectedQuoteId: String,
        includedAddonIds: [String]
    ) async throws -> (premium: hCore.Premium, displayItems: [hCoreUI.QuoteDisplayItem]) {
        removedAddonIds =
            moveQuotesModel?.homeQuotes.first(where: { $0.id == selectedQuoteId })?.addons
            .filter({ !includedAddonIds.contains($0.id) }).map { $0.id } ?? []
        let data = try await service.getMoveIntentCost(
            input: .init(
                intentId: moveConfigurationModel?.id ?? "",
                selectedHomeQuoteId: selectedQuoteId,
                selectedAddons: includedAddonIds
            )
        )
        let quote = data.quoteCosts.first(where: { $0.id == selectedQuoteId })!
        totalPremium = data.totalCost
        moveQuotesModel?.homeQuotes.enumerated()
            .forEach { (index, quote) in
                if let cost = data.quoteCosts.first(where: { $0.id == quote.id })?.cost {
                    moveQuotesModel?.homeQuotes[index].totalPremium = cost.premium
                    moveQuotesModel?.homeQuotes[index].priceBreakdownItems = cost.discounts.map({
                        .init(displaySubtitle: nil, displayTitle: $0.displayName, displayValue: $0.displayValue)
                    })
                }
            }
        moveQuotesModel?.mtaQuotes.enumerated()
            .forEach { (index, quote) in
                if let cost = data.quoteCosts.first(where: { $0.id == quote.id })?.cost {
                    moveQuotesModel?.mtaQuotes[index].totalPremium = cost.premium
                    moveQuotesModel?.mtaQuotes[index].priceBreakdownItems = cost.discounts.map({
                        .init(displaySubtitle: nil, displayTitle: $0.displayName, displayValue: $0.displayValue)
                    })
                }
            }
        return (quote.cost.premium, quote.cost.discounts.map({ .init(title: $0.displayName, value: $0.displayValue) }))
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
    case housing
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
        case .housing:
            return .init(describing: MovingFlowHousingTypeScreen.self)
        }
    }
}

struct ExtraBuildingTypeNavigationModel: Identifiable, Equatable {
    static func == (lhs: ExtraBuildingTypeNavigationModel, rhs: ExtraBuildingTypeNavigationModel) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID().uuidString
    var extraBuildingType: ExtraBuildingType?

    var addExtraBuildingVm: MovingFlowAddExtraBuildingViewModel
}

public struct MovingFlowNavigation: View {
    @StateObject private var movingFlowNavigationVm = MovingFlowNavigationViewModel()
    @StateObject var router = Router()
    private let onMoved: () -> Void
    @State var cancellable: AnyCancellable?

    public init(
        onMoved: @escaping () -> Void
    ) {
        self.onMoved = onMoved
    }

    public var body: some View {
        RouterHost(
            router: router,
            tracking: movingFlowNavigationVm.initialTrackingType ?? MovingFlowDetentType.selectHousingType
        ) {
            getInitalScreen()
                .routerDestination(for: HousingType.self) { _ in
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
                    case .housing:
                        openSelectHousingScreen()
                    case .confirm:
                        openConfirmScreen()
                    case .houseFill:
                        openHouseFillScreen()
                    case let .selectTier(model):
                        openChangeTier(model: model)
                    }
                }
        }
        .loading(
            $movingFlowNavigationVm.viewState,
            errorTitle: movingFlowNavigationVm.errorTitle,
            errorTrackingNameWithRouter: (MovingFlowDetentType.error, router)
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: { [weak router] in
                        router?.dismiss()
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                )
            )
        )
        .environmentObject(movingFlowNavigationVm)
        .detent(
            item: $movingFlowNavigationVm.isAddExtraBuildingPresented,
            transitionType: .detent(style: [.height])
        ) { houseInformationInputModel in
            MovingFlowAddExtraBuildingScreen(
                houseInformationInputVm: houseInformationInputModel
            )
            .environmentObject(movingFlowNavigationVm)
            .navigationTitle(L10n.changeAddressAddBuilding)
            .embededInNavigation(
                options: [.navigationType(type: .large)],
                tracking: MovingFlowDetentType.addExtraBuilding
            )
        }
        .detent(
            item: $movingFlowNavigationVm.document,
            transitionType: .detent(style: [.large])
        ) { document in
            PDFPreview(document: document)
        }
        .detent(
            item: $movingFlowNavigationVm.isBuildingTypePickerPresented,

            options: .constant([.alwaysOpenOnTop])
        ) { model in
            openTypeOfBuildingPicker(
                for: model.extraBuildingType,
                addExtraBuilingViewModel: model.addExtraBuildingVm
            )
        }
        .onDeinit {
            onMoved()
        }
    }

    @ViewBuilder
    func getInitalScreen() -> some View {
        let intentVm = movingFlowNavigationVm.moveConfigurationModel
        if intentVm?.currentHomeAddresses.count ?? 0 > 1 {
            openSelectInsuranceScreen()
        } else {
            openSelectHousingScreen()
        }
    }

    func openSelectInsuranceScreen() -> some View {
        MovingFlowSelectContractScreen(navigationVm: movingFlowNavigationVm, router: router)
            .withAlertDismiss()
    }

    func openSelectHousingScreen() -> some View {
        MovingFlowHousingTypeScreen(movingFlowNavigationVm: movingFlowNavigationVm)
            .withAlertDismiss()
    }

    func openApartmentFillScreen() -> some View {
        MovingFlowAddressScreen(vm: movingFlowNavigationVm.addressInputModel)
            .withAlertDismiss()
    }

    func openHouseFillScreen() -> some View {
        MovingFlowHouseScreen(houseInformationInputvm: movingFlowNavigationVm.houseInformationInputvm)
            .withAlertDismiss()
    }

    func openConfirmScreen() -> some View {
        movingFlowNavigationVm.setMovingFlowSummaryViewModel(
            router: router
        )
        let model = movingFlowNavigationVm.quoteSummaryViewModel!
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
        let model = ChangeTierInput.existingIntent(intent: model) {
            [weak movingFlowNavigationVm, weak router] _, quote in
            let requestVm = movingFlowNavigationVm?.moveQuotesModel
            let id = quote.id
            if let currentHomeQuote = requestVm?.homeQuotes.first(where: { $0.id == id }) {
                movingFlowNavigationVm?.selectedHomeQuote = currentHomeQuote
            }
            if let requestVm {
                movingFlowNavigationVm?.moveQuotesModel = requestVm
            }

            router?.push(MovingFlowRouterActions.confirm)
        }
        return ChangeTierNavigation(
            input: model,
            dataProvider: movingFlowNavigationVm,
            router: router
        )
    }

    func openTypeOfBuildingPicker(
        for currentlySelected: ExtraBuildingType?,
        addExtraBuilingViewModel: MovingFlowAddExtraBuildingViewModel
    ) -> some View {
        TypeOfBuildingPickerScreen(
            currentlySelected: currentlySelected,
            movingFlowNavigationVm: movingFlowNavigationVm,
            addExtraBuidlingViewModel: addExtraBuilingViewModel
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
            return .init(describing: MovingFlowHousingTypeScreen.self)
        case .addExtraBuilding:
            return .init(describing: MovingFlowAddExtraBuildingScreen.self)
        case .typeOfBuildingPicker:
            return .init(describing: TypeOfBuildingPickerScreen.self)
        case .selectContract:
            return .init(describing: MovingFlowSelectContractScreen.self)
        case .error:
            return "Moving flow error screen"
        }
    }

    case selectHousingType
    case addExtraBuilding
    case typeOfBuildingPicker
    case selectContract
    case error
}

@MainActor
extension AddonDataModel {
    func asContractInfo(
        ondocumentClicked: @escaping (hPDFDocument) -> Void
    ) -> QuoteSummaryViewModel.ContractInfo {
        let addonQuoteContractInfo = QuoteSummaryViewModel.ContractInfo(
            id: id,
            displayName: quoteInfo.title ?? "",
            exposureName: coverageDisplayName,
            premium: .init(
                gross: grossPremium,
                net: nil
            ),
            documentSection: .init(
                documents: addonVariant.documents,
                onTap: { document in
                    ondocumentClicked(document)
                }
            ),
            displayItems: displayItems.map {
                .init(title: $0.displayTitle, value: $0.displayValue)
            },
            insuranceLimits: [],
            typeOfContract: nil,
            isAddon: true,
            priceBreakdownItems: []
        )
        return addonQuoteContractInfo
    }
}
