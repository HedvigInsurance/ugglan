import SwiftUI
import hCore
import hCoreUI

@MainActor
class EditCoInsuredNavigationViewModel: ObservableObject {
    init(
        config: InsuredPeopleConfig
    ) {
        coInsuredViewModel.initializeCoInsured(with: config)
    }

    @Published var editCoInsuredConfig: InsuredPeopleConfig?
    @Published var coInsuredInputModel: CoInsuredInputModel?
    @Published var selectCoInsured: SelectCoInsured?
    @Published var showProgressScreenWithSuccess = false
    @Published var showProgressScreenWithoutSuccess = false

    @Published var isEditCoinsuredSelectPresented: InsuredPeopleConfig?

    let coInsuredViewModel = InsuredPeopleScreenViewModel()
    let intentViewModel = IntentViewModel()
}

extension EditCoInsuredScreenType {
    func getTrackingType(for config: InsuredPeopleConfig) -> EditCoInsuredScreenTrackingType {
        switch self {
        case .newInsurance:
            return .newInsurance
        case .none:
            if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                if config.fromInfoCard {
                    return .newInsurance
                } else {
                    return .removeCoInsured
                }
            } else if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                return .newInsurance
            } else {
                return .insuredPeople
            }
        }
    }
}

enum EditCoInsuredScreenTrackingType: TrackingViewNameProtocol {

    case newInsurance
    case removeCoInsured
    case insuredPeople

    var nameForTracking: String {
        switch self {
        case .newInsurance:
            return .init(describing: InsuredPeopleScreen.self)
        case .removeCoInsured:
            return .init(describing: InsuredPeopleScreen.self)
        case .insuredPeople:
            return .init(describing: InsuredPeopleScreen.self)
        }
    }
}

private enum EditCoInsuredDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .coInsuredInput:
            return .init(describing: CoInusuredInputScreen.self)
        case .selectCoInsured:
            return .init(describing: SelectCoInsured.self)
        }
    }

    case coInsuredInput
    case selectCoInsured
}

public struct EditCoInsuredNavigation: View {
    let config: InsuredPeopleConfig
    @State var openSpecificScreen: EditCoInsuredScreenType
    @ObservedObject private var editCoInsuredNavigationVm: EditCoInsuredNavigationViewModel
    @StateObject var router = Router()
    @EnvironmentObject var editCoInsuredViewModel: EditCoInsuredViewModel

    public init(
        config: InsuredPeopleConfig,
        openSpecificScreen: EditCoInsuredScreenType? = EditCoInsuredScreenType.none
    ) {
        self.config = config
        self.openSpecificScreen = openSpecificScreen ?? .none
        self.editCoInsuredNavigationVm = .init(config: config)
    }

    public var body: some View {
        RouterHost(
            router: router,
            options: .navigationType(type: .large),
            tracking: openSpecificScreen.getTrackingType(for: config)
        ) {
            if openSpecificScreen == .newInsurance {
                openNewInsuredPeopleScreen()
            } else if openSpecificScreen == .none {
                if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                    if config.fromInfoCard {
                        openNewInsuredPeopleScreen()
                    } else {
                        openRemoveCoInsuredScreen()
                    }
                } else if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                    openNewInsuredPeopleScreen()
                } else {
                    openInsuredPeopleScreen()
                }
            }
        }
        .modally(item: $editCoInsuredNavigationVm.editCoInsuredConfig) { config in
            EditCoInsuredNavigation(
                config: config
            )
            .environmentObject(editCoInsuredViewModel)
        }
        .detent(
            item: $editCoInsuredNavigationVm.coInsuredInputModel,
            transitionType: .detent(style: [.height])
        ) { coInsuredInputModel in
            coInsuredInput(coInsuredInputModel: coInsuredInputModel)
                .embededInNavigation(
                    options: [.navigationType(type: .large)],
                    tracking: EditCoInsuredDetentType.coInsuredInput
                )
        }
        .detent(
            item: $editCoInsuredNavigationVm.selectCoInsured,
            transitionType: .detent(style: [.height])
        ) { selectCoInsured in
            openCoInsuredSelectScreen(contractId: selectCoInsured.id)
                .environmentObject(editCoInsuredNavigationVm)
                .embededInNavigation(
                    options: [.navigationType(type: .large)],
                    tracking: EditCoInsuredDetentType.selectCoInsured
                )
        }
        .modally(presented: $editCoInsuredNavigationVm.showProgressScreenWithSuccess) {
            openProgress(showSuccess: true)
        }
        .modally(presented: $editCoInsuredNavigationVm.showProgressScreenWithoutSuccess) {
            openProgress(showSuccess: false)
        }
        .modally(item: $editCoInsuredNavigationVm.isEditCoinsuredSelectPresented) { editConfig in
            let _ = editCoInsuredNavigationVm.coInsuredViewModel.initializeCoInsured(with: editConfig)
            openNewInsuredPeopleScreen()
                .environmentObject(router)
        }
        .environmentObject(editCoInsuredNavigationVm)
    }

    func openNewInsuredPeopleScreen() -> some View {
        openSpecificScreen = .none
        return openInsuredPeopleScreen()
    }

    func openInsuredPeopleScreen() -> some View {
        return InsuredPeopleScreen(
            vm: editCoInsuredNavigationVm.coInsuredViewModel,
            intentViewModel: editCoInsuredNavigationVm.intentViewModel,
            type: .none
        )
        .configureTitle(L10n.coinsuredEditTitle)
        .addDismissEditCoInsuredFlow()
    }

    func openCoInsuredInput(
        coInsuredModelEdit: CoInsuredInputModel
    ) -> some View {
        CoInusuredInputScreen(
            vm: .init(
                coInsuredModel: coInsuredModelEdit.coInsuredModel,
                actionType: coInsuredModelEdit.actionType,
                contractId: coInsuredModelEdit.contractId
            ),
            title: coInsuredModelEdit.title,
            editCoInsuredNavigation: editCoInsuredNavigationVm
        )
        .environmentObject(editCoInsuredNavigationVm)
        .configureTitle(L10n.contractAddConisuredInfo)
    }

    func openCoInsuredSelectScreen(contractId: String) -> some View {
        CoInsuredSelectScreen(contractId: contractId, editCoInsuredNavigation: editCoInsuredNavigationVm)
            .configureTitle(L10n.contractAddConisuredInfo)
    }

    func openProgress(showSuccess: Bool) -> some View {
        CoInsuredProcessingScreen(
            showSuccessScreen: showSuccess,
            intentVM: editCoInsuredNavigationVm.intentViewModel
        )
        .environmentObject(editCoInsuredNavigationVm)
        .environmentObject(editCoInsuredViewModel)
    }

    func openRemoveCoInsuredScreen() -> some View {
        return InsuredPeopleScreen(
            vm: editCoInsuredNavigationVm.coInsuredViewModel,
            intentViewModel: editCoInsuredNavigationVm.intentViewModel,
            type: .delete
        )
        .configureTitle(L10n.coinsuredEditTitle)
    }

    func coInsuredInput(coInsuredInputModel: CoInsuredInputModel) -> some View {
        openCoInsuredInput(
            coInsuredModelEdit: coInsuredInputModel
        )
    }
}

public struct EditCoInsuredSelectInsuranceNavigation: View {
    let configs: [InsuredPeopleConfig]
    @StateObject var router = Router()
    @EnvironmentObject var editCoInsuredViewModel: EditCoInsuredViewModel
    @StateObject var editCoInsuredNavigationVm = EditCoInsuredNavigationViewModel(config: .init())

    public init(
        configs: [InsuredPeopleConfig]
    ) {
        self.configs = configs
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large), tracking: self) {
            openSelectInsurance()
        }
    }

    func openSelectInsurance() -> some View {
        CoInsuredSelectInsuranceScreen(
            configs: configs,
            editCoInsuredNavigationVm: editCoInsuredNavigationVm,
            editCoInsuredViewModel: editCoInsuredViewModel,
            router: router
        )
    }
}

extension EditCoInsuredSelectInsuranceNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: CoInsuredSelectInsuranceScreen.self)
    }
}

public struct EditCoInsuredAlertNavigation: View {
    let config: InsuredPeopleConfig
    @StateObject var router = Router()
    @EnvironmentObject private var editCoInsuredViewModel: EditCoInsuredViewModel

    public init(
        config: InsuredPeopleConfig
    ) {
        self.config = config
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large), tracking: self) {
            openMissingCoInsuredAlert()
        }
    }

    public func openMissingCoInsuredAlert() -> some View {
        return MissingCoInsuredAlert(
            config: config,
            onButtonAction: { [weak editCoInsuredViewModel] in
                editCoInsuredViewModel?.editCoInsuredModelMissingAlert = nil
                editCoInsuredViewModel?.editCoInsuredModelFullScreen = .init(
                    openSpecificScreen: .newInsurance,
                    contractsSupportingCoInsured: {
                        [config]
                    }
                )
            }
        )
    }
}
extension EditCoInsuredAlertNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: MissingCoInsuredAlert.self)
    }
}

extension View {
    func addDismissEditCoInsuredFlow() -> some View {
        self.withDismissButton(
            title: L10n.General.areYouSure,
            message: L10n.Claims.Alert.body,
            confirmButton: L10n.General.yes,
            cancelButton: L10n.General.no
        )
    }
}

public struct SelectCoInsured: Identifiable, Equatable {
    public var id: String
}
