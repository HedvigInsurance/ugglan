import EditCoInsuredShared
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class EditCoInsuredNavigationViewModel: ObservableObject {
    public init() {}

    @Published var editCoInsuredConfig: InsuredPeopleConfig?
    @Published var coInsuredInputModel: CoInsuredInputModel?
    @Published var selectCoInsured: SelectCoInsured?
    @Published var showProgressScreenWithSuccess = false
    @Published var showProgressScreenWithoutSuccess = false

    @Published var isEditCoinsuredSelectPresented: InsuredPeopleConfig?
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
            return .init(describing: InsuredPeopleNewScreen.self)
        case .removeCoInsured:
            return .init(describing: RemoveCoInsuredScreen.self)
        case .insuredPeople:
            return .init(describing: InsuredPeopleScreen.self)
        }
    }
}

public struct EditCoInsuredNavigation: View {
    let config: InsuredPeopleConfig
    @State var openSpecificScreen: EditCoInsuredScreenType
    @StateObject private var editCoInsuredNavigationVm = EditCoInsuredNavigationViewModel()
    @StateObject var router = Router()
    @EnvironmentObject var editCoInsuredViewModel: EditCoInsuredViewModel

    public init(
        config: InsuredPeopleConfig,
        openSpecificScreen: EditCoInsuredScreenType? = EditCoInsuredScreenType.none
    ) {
        self.config = config
        self.openSpecificScreen = openSpecificScreen ?? .none

        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.initializeCoInsured(with: config)
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
            style: .height
        ) { coInsuredInputModel in
            coInsuredInput(coInsuredInputModel: coInsuredInputModel)
                .embededInNavigation(options: [.navigationType(type: .large)])
        }
        .detent(
            item: $editCoInsuredNavigationVm.selectCoInsured,
            style: .height
        ) { selectCoInsured in
            openCoInsuredSelectScreen(contractId: selectCoInsured.id)
                .environmentObject(editCoInsuredNavigationVm)
        }
        .modally(presented: $editCoInsuredNavigationVm.showProgressScreenWithSuccess) {
            openProgress(showSuccess: true)
        }
        .modally(presented: $editCoInsuredNavigationVm.showProgressScreenWithoutSuccess) {
            openProgress(showSuccess: false)
        }
        .modally(item: $editCoInsuredNavigationVm.isEditCoinsuredSelectPresented) { editConfig in
            let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
            let _ = store.coInsuredViewModel.initializeCoInsured(with: editConfig)
            openNewInsuredPeopleScreen()
                .environmentObject(router)
        }
        .environmentObject(editCoInsuredNavigationVm)
    }

    func openNewInsuredPeopleScreen() -> some View {
        openSpecificScreen = .none
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        return InsuredPeopleNewScreen(
            vm: store.coInsuredViewModel,
            intentVm: store.intentViewModel
        )
        .configureTitle(L10n.coinsuredEditTitle)
        .addDismissEditCoInsuredFlow()
    }

    func openInsuredPeopleScreen() -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        return InsuredPeopleScreen(
            vm: store.coInsuredViewModel,
            intentVm: store.intentViewModel
        )
        .configureTitle(L10n.coinsuredEditTitle)
        .addDismissEditCoInsuredFlow()
    }

    func openCoInsuredInput(
        coInsuredModelEdit: CoInsuredInputModel
    ) -> some View {
        CoInusuredInput(
            vm: .init(
                coInsuredModel: coInsuredModelEdit.coInsuredModel,
                actionType: coInsuredModelEdit.actionType,
                contractId: coInsuredModelEdit.contractId
            ),
            title: coInsuredModelEdit.title
        )
        .environmentObject(editCoInsuredNavigationVm)
        .configureTitle(L10n.contractAddConisuredInfo)
    }

    func openCoInsuredSelectScreen(contractId: String) -> some View {
        CoInsuredSelectScreen(contractId: contractId)
            .configureTitle(L10n.contractAddConisuredInfo)
    }

    func openProgress(showSuccess: Bool) -> some View {
        CoInsuredProcessingScreen(
            showSuccessScreen: showSuccess
        )
        .environmentObject(editCoInsuredNavigationVm)
        .environmentObject(editCoInsuredViewModel)
    }

    func openSuccessScreen(title: String) -> some View {
        hForm {
            SuccessScreen(title: title)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        editCoInsuredNavigationVm.coInsuredInputModel = nil
                    }
                }
        }
    }

    func openRemoveCoInsuredScreen() -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        return RemoveCoInsuredScreen(
            vm: store.coInsuredViewModel
        )
        .configureTitle(L10n.coinsuredEditTitle)
    }

    func coInsuredInput(coInsuredInputModel: CoInsuredInputModel) -> some View {
        openCoInsuredInput(
            coInsuredModelEdit: coInsuredInputModel
        )
        .routerDestination(for: CoInsuredAction.self, options: .hidesBackButton) { actionType in
            var title: String {
                switch actionType {
                case .add:
                    return L10n.contractCoinsuredAdded
                case .delete:
                    return L10n.contractCoinsuredRemoved
                default:
                    return ""
                }
            }
            openSuccessScreen(title: title)
        }
    }
}

public struct EditCoInsuredSelectInsuranceNavigation: View {
    let configs: [InsuredPeopleConfig]
    @StateObject var router = Router()
    @EnvironmentObject var editCoInsuredViewModel: EditCoInsuredViewModel

    public init(
        configs: [InsuredPeopleConfig]
    ) {
        self.configs = configs
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large)) {
            openSelectInsurance()
        }
    }

    func openSelectInsurance() -> some View {
        CheckboxPickerScreen<InsuredPeopleConfig>(
            items: {
                return configs.compactMap({
                    (object: $0, displayName: .init(title: $0.displayName))
                })
            }(),
            preSelectedItems: {
                if let first = configs.first {
                    return [first]
                }
                return []
            },
            onSelected: { [weak editCoInsuredViewModel] selectedConfigs in
                if let selectedConfig = selectedConfigs.first {
                    if let object = selectedConfig.0 {
                        editCoInsuredViewModel?.editCoInsuredModelDetent = nil
                        editCoInsuredViewModel?.editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                            return [object]
                        })
                        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                        store.coInsuredViewModel.initializeCoInsured(with: object)
                    }
                }
            },
            onCancel: { [weak router] in
                router?.dismiss()
            },
            singleSelect: true,
            hButtonText: L10n.generalContinueButton
        )
        .configureTitle(L10n.SelectInsurance.NavigationBar.CenterElement.title)
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
        RouterHost(router: router, options: .navigationType(type: .large)) {
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
