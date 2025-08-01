import ChangeTier
import Combine
import hCore
import hCoreUI
import SwiftUI

@MainActor
public class MovingFlowNavigationViewModel: ObservableObject {
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

    var movingFlowConfirmViewModel: MovingFlowConfirmViewModel?
    var quoteSummaryViewModel: QuoteSummaryViewModel?
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
            let contractQuote = QuoteSummaryViewModel.ContractInfo(
                id: quote.id,
                displayName: quote.displayName,
                exposureName: quote.exposureName ?? "",
                newPremium: quote.premium,
                currentPremium: quote.premium,
                documents: quote.documents.map {
                    .init(displayName: $0.displayName, url: $0.url, type: .unknown)
                },
                onDocumentTap: { [weak self] document in
                    self?.document = document
                },
                displayItems: quote.displayItems.map({ .init(title: $0.displayTitle, value: $0.displayValue) }
                ),
                insuranceLimits: quote.insurableLimits,
                typeOfContract: quote.contractType
            )
            contractInfos.append(contractQuote)

            for addonQuote in quote.addons {
                let addonQuoteContractInfo = addonQuote.asContractInfo {
                    [weak self] document in
                    self?.document = document
                }
                contractInfos.append(addonQuoteContractInfo)
            }
        }

        let vm = QuoteSummaryViewModel(
            contract: contractInfos
        )
        vm.onConfirmClick = { [weak self, weak router, weak vm] in
            Task {
                guard let self = self,
                      let movingFlowConfirmViewModel = self.movingFlowConfirmViewModel,
                      let vm
                else { return }
                await movingFlowConfirmViewModel.confirmMoveIntent(
                    intentId: self.moveConfigurationModel?.id ?? "",
                    currentHomeQuoteId: self.selectedHomeQuote?.id ?? "",
                    removedAddons: vm.getRemovedContractsIds()
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
        selectedHomeQuote?.startDate ?? moveQuotesModel?.mtaQuotes.first?.startDate ?? ""
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
        let model = ChangeTierInput.existingIntent(intent: model) { _, quote in
            let requestVm = movingFlowNavigationVm.moveQuotesModel
            let id = quote.id
            if let currentHomeQuote = requestVm?.homeQuotes.first(where: { $0.id == id }) {
                movingFlowNavigationVm.selectedHomeQuote = currentHomeQuote
            }
            if let requestVm {
                movingFlowNavigationVm.moveQuotesModel = requestVm
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
        let removeModel: QuoteSummaryViewModel.ContractInfo.RemoveModel? = {
            if let removeDialogInfo = self.removeDialogInfo {
                return .init(
                    id: self.id,
                    title: removeDialogInfo.title,
                    description: removeDialogInfo.description,
                    confirmButtonTitle: removeDialogInfo.confirmButtonTitle,
                    cancelRemovalButtonTitle: removeDialogInfo.cancelButtonTitle
                )
            }
            return nil
        }()
        let addonQuoteContractInfo = QuoteSummaryViewModel.ContractInfo(
            id: id,
            displayName: quoteInfo.title ?? "",
            exposureName: coverageDisplayName,
            newPremium: price,
            currentPremium: nil,
            documents: addonVariant.documents,
            onDocumentTap: { document in
                ondocumentClicked(document)
            },
            displayItems: displayItems.map {
                .init(title: $0.displayTitle, value: $0.displayValue)
            },
            insuranceLimits: [],
            typeOfContract: nil,
            isAddon: true,
            removeModel: removeModel
        )
        return addonQuoteContractInfo
    }
}
