import SwiftUI
import hCore
import hCoreUI

@MainActor
class EditCoInsuredNavigationViewModel: ObservableObject {
    init(config: StakeHoldersConfig) {
        coInsuredViewModel = .init(with: config)
    }

    @Published var editCoInsuredConfig: StakeHoldersConfig?
    @Published var coInsuredInputModel: CoInsuredInputModel?
    @Published var selectCoInsured: SelectCoInsured?
    @Published var showProgressScreenWithSuccess = false
    @Published var showProgressScreenWithoutSuccess = false
    @Published var isEditCoinsuredSelectPresented: StakeHoldersConfig?

    let coInsuredViewModel: InsuredPeopleScreenViewModel
    let intentViewModel = IntentViewModel()
}

// TODO: fix
extension EditCoInsuredScreenType {
    func getTrackingType(for config: StakeHoldersConfig) -> EditCoInsuredScreenTrackingType {
        switch self {
        case .newInsurance:
            return .newInsurance
        case .none:
            if config.numberOfMissingStakeHoldersWithoutTermination > 0 {
                if config.fromInfoCard {
                    return .newInsurance
                } else {
                    return .removeCoInsured
                }
            }
            return .insuredPeople
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
    let config: StakeHoldersConfig
    @State var openSpecificScreen: EditCoInsuredScreenType
    @ObservedObject private var editCoInsuredNavigationVm: EditCoInsuredNavigationViewModel
    @StateObject var router = Router()
    @EnvironmentObject var editCoInsuredViewModel: EditCoInsuredViewModel

    public init(
        config: StakeHoldersConfig,
        openSpecificScreen: EditCoInsuredScreenType? = EditCoInsuredScreenType.none
    ) {
        self.config = config
        self.openSpecificScreen = openSpecificScreen ?? .none
        editCoInsuredNavigationVm = .init(config: config)
    }

    //    switch config.stakeHolderType {
    //    case .coInsured:
    //        if config.numberOfMissingStakeHoldersWithoutTermination > 0 {
    //            if config.fromInfoCard {
    //                openNewInsuredPeopleScreen()
    //            } else {
    //                openRemoveCoInsuredScreen()
    //            }
    //        } else {
    //            openNewInsuredPeopleScreen()
    //        }
    //    case .coOwner: openNewInsuredPeopleScreen()
    //    }

    public var body: some View {
        RouterHost(
            router: router,
            options: [.navigationType(type: .large), .extendedNavigationWidth],
            tracking: openSpecificScreen.getTrackingType(for: config)
        ) {
            if openSpecificScreen == .newInsurance {
                openNewInsuredPeopleScreen()
            } else if openSpecificScreen == .none {
                if config.numberOfMissingStakeHoldersWithoutTermination > 0 {
                    if config.fromInfoCard {
                        openNewInsuredPeopleScreen()
                    } else {
                        openRemoveCoInsuredScreen()
                    }
                } else {
                    openNewInsuredPeopleScreen()
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
                    options: [.navigationType(type: .large), .extendedNavigationWidth],
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
                    options: [.navigationType(type: .large), .extendedNavigationWidth],
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
        InsuredPeopleScreen(
            vm: editCoInsuredNavigationVm.coInsuredViewModel,
            intentViewModel: editCoInsuredNavigationVm.intentViewModel,
            type: .none
        )
        .configureTitle(config.stakeHolderType.editTitle)
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
        .configureTitle(config.stakeHolderType.addInfoTitle)
    }

    func openCoInsuredSelectScreen(contractId: String) -> some View {
        CoInsuredSelectScreen(contractId: contractId, editCoInsuredNavigation: editCoInsuredNavigationVm)
            .configureTitle(config.stakeHolderType.addInfoTitle)
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
        InsuredPeopleScreen(
            vm: editCoInsuredNavigationVm.coInsuredViewModel,
            intentViewModel: editCoInsuredNavigationVm.intentViewModel,
            type: .delete
        )
        .configureTitle(config.stakeHolderType.editTitle)
    }

    func coInsuredInput(coInsuredInputModel: CoInsuredInputModel) -> some View {
        openCoInsuredInput(
            coInsuredModelEdit: coInsuredInputModel
        )
    }
}

public struct EditCoInsuredSelectInsuranceNavigation: View {
    let configs: [StakeHoldersConfig]
    @StateObject var router = Router()
    @EnvironmentObject var editCoInsuredViewModel: EditCoInsuredViewModel
    @StateObject var editCoInsuredNavigationVm: EditCoInsuredNavigationViewModel

    public init(
        configs: [StakeHoldersConfig],
        stakeHolderType: StakeHolderType
    ) {
        self.configs = configs
        _editCoInsuredNavigationVm = .init(wrappedValue: .init(config: .init(stakeHolderType: stakeHolderType)))
    }

    public var body: some View {
        RouterHost(router: router, options: [.navigationType(type: .large), .extendedNavigationWidth], tracking: self) {
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
        .init(describing: CoInsuredSelectInsuranceScreen.self)
    }
}

public struct EditCoInsuredAlertNavigation: View {
    let config: StakeHoldersConfig
    @StateObject var router = Router()
    @EnvironmentObject private var editCoInsuredViewModel: EditCoInsuredViewModel

    public init(
        config: StakeHoldersConfig
    ) {
        self.config = config
    }

    public var body: some View {
        RouterHost(router: router, options: [.navigationType(type: .large), .extendedNavigationWidth], tracking: self) {
            openMissingCoInsuredAlert()
        }
    }

    public func openMissingCoInsuredAlert() -> some View {
        MissingCoInsuredAlert(
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
        .init(describing: MissingCoInsuredAlert.self)
    }
}

extension View {
    func addDismissEditCoInsuredFlow() -> some View {
        withAlertDismiss()
    }
}

public struct SelectCoInsured: Identifiable, Equatable {
    public var id: String
}
