import SwiftUI
import hCore
import hCoreUI

@MainActor
class EditStakeholdersNavigationViewModel: ObservableObject {
    init(config: StakeholdersConfig) {
        stakeholderViewModel = .init(with: config)
    }

    @Published var editStakeholderConfig: StakeholdersConfig?
    @Published var stakeholderInputModel: StakeholderInputModel?
    @Published var selectStakeholder: SelectStakeholder?
    @Published var showProgressScreenWithSuccess = false
    @Published var showProgressScreenWithoutSuccess = false
    @Published var isEditStakeholderSelectPresented: StakeholdersConfig?

    let stakeholderViewModel: StakeholdersViewModel
    let intentViewModel = IntentViewModel()
}

enum StakeholderScreenTrackingType {
    case newInsurance(StakeholderType)
    case removeStakeholder(StakeholderType)
    case stakeholders(StakeholderType)
    case input(StakeholderType)
    case select(StakeholderType)
}

extension StakeholderScreenTrackingType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .newInsurance(let type): type.trackingName(for: "ListScreen")
        case .removeStakeholder(let type): type.trackingName(for: "ListScreen")
        case .stakeholders(let type): type.trackingName(for: "ListScreen")
        case .input(let type): type.trackingName(for: "InputScreen")
        case .select(let type): type.trackingName(for: "SelectScreen")
        }
    }
}

extension EditStakeholdersScreenType {
    func getTrackingType(for config: StakeholdersConfig) -> StakeholderScreenTrackingType {
        switch self {
        case .newInsurance: .newInsurance(config.stakeholderType)
        case .none:
            if config.numberOfMissingStakeholdersWithoutTermination > 0 {
                config.fromInfoCard
                    ? .newInsurance(config.stakeholderType)
                    : .removeStakeholder(config.stakeholderType)
            } else {
                .stakeholders(config.stakeholderType)
            }
        }
    }
}

public struct EditStakeholdersNavigation: View {
    let config: StakeholdersConfig
    @State var openSpecificScreen: EditStakeholdersScreenType
    @ObservedObject private var editStakeholdersNavigationVm: EditStakeholdersNavigationViewModel
    @StateObject var router = NavigationRouter()
    @EnvironmentObject var editStakeholdersViewModel: EditStakeholdersViewModel

    public init(
        config: StakeholdersConfig,
        openSpecificScreen: EditStakeholdersScreenType? = EditStakeholdersScreenType.none
    ) {
        self.config = config
        self.openSpecificScreen = openSpecificScreen ?? .none
        editStakeholdersNavigationVm = .init(config: config)
    }

    public var body: some View {
        hNavigationStack(
            router: router,
            options: [.navigationType(type: .large), .extendedNavigationWidth],
            tracking: openSpecificScreen.getTrackingType(for: config)
        ) {
            switch openSpecificScreen {
            case .newInsurance: openNewStakeholdersScreen()
            case .none:
                if config.numberOfMissingStakeholdersWithoutTermination > 0 {
                    if config.fromInfoCard {
                        openNewStakeholdersScreen()
                    } else {
                        openRemoveStakeholderScreen()
                    }
                } else {
                    openStakeholdersScreen()
                }
            }
        }
        .modally(item: $editStakeholdersNavigationVm.editStakeholderConfig) { config in
            EditStakeholdersNavigation(
                config: config
            )
            .environmentObject(editStakeholdersViewModel)
        }
        .detent(
            item: $editStakeholdersNavigationVm.stakeholderInputModel,
            presentationStyle: .detent(style: [.height])
        ) { stakeholderInputModel in
            stakeholderInput(stakeholderInputModel: stakeholderInputModel)
                .embededInNavigation(
                    options: [.navigationType(type: .large), .extendedNavigationWidth],
                    tracking: StakeholderScreenTrackingType.input(config.stakeholderType)
                )
        }
        .detent(
            item: $editStakeholdersNavigationVm.selectStakeholder,
            presentationStyle: .detent(style: [.height])
        ) { selectStakeholder in
            openStakeholderSelectScreen(contractId: selectStakeholder.id)
                .environmentObject(editStakeholdersNavigationVm)
                .embededInNavigation(
                    options: [.navigationType(type: .large), .extendedNavigationWidth],
                    tracking: StakeholderScreenTrackingType.select(config.stakeholderType)
                )
        }
        .modally(presented: $editStakeholdersNavigationVm.showProgressScreenWithSuccess) {
            openProgress(showSuccess: true)
        }
        .modally(presented: $editStakeholdersNavigationVm.showProgressScreenWithoutSuccess) {
            openProgress(showSuccess: false)
        }
        .modally(item: $editStakeholdersNavigationVm.isEditStakeholderSelectPresented) { editConfig in
            let _ = editStakeholdersNavigationVm.stakeholderViewModel.initializeStakeholders(with: editConfig)
            openNewStakeholdersScreen()
                .environmentObject(router)
        }
        .environmentObject(editStakeholdersNavigationVm)
    }

    func openNewStakeholdersScreen() -> some View {
        openSpecificScreen = .none
        return openStakeholdersScreen()
    }

    func openStakeholdersScreen() -> some View {
        StakeholdersScreen(
            vm: editStakeholdersNavigationVm.stakeholderViewModel,
            intentViewModel: editStakeholdersNavigationVm.intentViewModel,
            type: .none
        )
        .navigationTitle(config.stakeholderType.editTitle)
        .addDismissEditStakeholdersFlow()
    }

    func openStakeholderInput(
        stakeholderModelEdit: StakeholderInputModel
    ) -> some View {
        StakeholderInputScreen(
            vm: .init(
                stakeholderModel: stakeholderModelEdit.stakeholderModel,
                actionType: stakeholderModelEdit.actionType,
                contractId: stakeholderModelEdit.contractId
            ),
            title: stakeholderModelEdit.title,
            editStakeholdersNavigation: editStakeholdersNavigationVm
        )
        .environmentObject(editStakeholdersNavigationVm)
        .navigationTitle(config.stakeholderType.addInfoTitle)
    }

    func openStakeholderSelectScreen(contractId: String) -> some View {
        StakeholderSelectScreen(contractId: contractId, editStakeholdersNavigation: editStakeholdersNavigationVm)
            .navigationTitle(config.stakeholderType.addInfoTitle)
    }

    func openProgress(showSuccess: Bool) -> some View {
        StakeholderProcessingScreen(
            showSuccessScreen: showSuccess,
            intentVM: editStakeholdersNavigationVm.intentViewModel
        )
        .environmentObject(editStakeholdersNavigationVm)
        .environmentObject(editStakeholdersViewModel)
    }

    func openRemoveStakeholderScreen() -> some View {
        StakeholdersScreen(
            vm: editStakeholdersNavigationVm.stakeholderViewModel,
            intentViewModel: editStakeholdersNavigationVm.intentViewModel,
            type: .delete
        )
        .navigationTitle(config.stakeholderType.editTitle)
    }

    func stakeholderInput(stakeholderInputModel: StakeholderInputModel) -> some View {
        openStakeholderInput(
            stakeholderModelEdit: stakeholderInputModel
        )
    }
}

public struct EditStakeholdersSelectInsuranceNavigation: View {
    let configs: [StakeholdersConfig]
    let stakeholderType: StakeholderType
    @StateObject var router = NavigationRouter()
    @EnvironmentObject var editStakeholdersViewModel: EditStakeholdersViewModel
    @StateObject var editStakeholdersNavigationVm: EditStakeholdersNavigationViewModel

    public init(
        configs: [StakeholdersConfig],
        stakeholderType: StakeholderType
    ) {
        self.configs = configs
        self.stakeholderType = stakeholderType
        _editStakeholdersNavigationVm = .init(wrappedValue: .init(config: .init(stakeholderType: stakeholderType)))
    }

    public var body: some View {
        hNavigationStack(
            router: router,
            options: [.navigationType(type: .large), .extendedNavigationWidth],
            tracking: self
        ) {
            openSelectInsurance()
        }
    }

    func openSelectInsurance() -> some View {
        StakeholderSelectInsuranceScreen(
            configs: configs,
            editStakeholdersNavigationVm: editStakeholdersNavigationVm,
            editStakeholdersViewModel: editStakeholdersViewModel,
            router: router
        )
    }
}

extension EditStakeholdersSelectInsuranceNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        stakeholderType.trackingName(for: "SelectInsuranceScreen")
    }
}

public struct EditStakeholdersAlertNavigation: View {
    let config: StakeholdersConfig
    @StateObject var router = NavigationRouter()
    @EnvironmentObject private var editStakeholdersViewModel: EditStakeholdersViewModel

    public init(
        config: StakeholdersConfig
    ) {
        self.config = config
    }

    public var body: some View {
        hNavigationStack(
            router: router,
            options: [.navigationType(type: .large), .extendedNavigationWidth],
            tracking: self
        ) {
            openMissingStakeholderAlert()
        }
    }

    public func openMissingStakeholderAlert() -> some View {
        MissingStakeholderAlert(
            config: config,
            onButtonAction: { [weak editStakeholdersViewModel] in
                editStakeholdersViewModel?.editStakeholderModelMissingAlert = nil
                editStakeholdersViewModel?.editStakeholderModelFullScreen = .init(
                    openSpecificScreen: .newInsurance,
                    contractsSupportingStakeholders: {
                        [config]
                    }
                )
            }
        )
    }
}

extension EditStakeholdersAlertNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        config.stakeholderType.trackingName(for: "MissingAlert")
    }
}

extension View {
    func addDismissEditStakeholdersFlow() -> some View {
        withAlertDismiss()
    }
}

public struct SelectStakeholder: Identifiable, Equatable {
    public var id: String
}
