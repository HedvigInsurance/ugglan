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

public enum EditCoInsuredScreenType {
    case newInsurance
    case none
}

public struct EditCoInsuredNavigation: View {
    let config: InsuredPeopleConfig
    @State var openSpecificScreen: EditCoInsuredScreenType
    @StateObject private var editCoInsuredNavigationVm = EditCoInsuredNavigationViewModel()
    @StateObject var router = Router()
    var checkForAlert: () -> Void

    public init(
        config: InsuredPeopleConfig,
        openSpecificScreen: EditCoInsuredScreenType? = EditCoInsuredScreenType.none,
        checkForAlert: @escaping () -> Void
    ) {
        self.config = config
        self.openSpecificScreen = openSpecificScreen ?? .none
        self.checkForAlert = checkForAlert

        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.initializeCoInsured(with: config)
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large)) {
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
        .fullScreenCover(item: $editCoInsuredNavigationVm.editCoInsuredConfig) { config in
            EditCoInsuredNavigation(
                config: config,
                checkForAlert: {
                    checkForAlert()
                }
            )
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
        .fullScreenCover(isPresented: $editCoInsuredNavigationVm.showProgressScreenWithSuccess) {
            openProgress(showSuccess: true)
                .environmentObject(router)
        }
        .fullScreenCover(isPresented: $editCoInsuredNavigationVm.showProgressScreenWithoutSuccess) {
            openProgress(showSuccess: false)
        }
        .fullScreenCover(item: $editCoInsuredNavigationVm.isEditCoinsuredSelectPresented) { editConfig in
            let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
            let _ = store.coInsuredViewModel.initializeCoInsured(with: editConfig)
            openNewInsuredPeopleScreen()
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
            showSuccessScreen: showSuccess,
            checkForMissingAlert: {
                checkForAlert()
            }
        )
    }

    func openSuccessScreen(title: String) -> some View {
        SuccessScreen(title: title)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    editCoInsuredNavigationVm.coInsuredInputModel = nil
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

public class EditCoInsuredSelectInsuranceNavigationViewModel: ObservableObject {
    @Published var editCoInsuredConfig: InsuredPeopleConfig?
}

public struct EditCoInsuredSelectInsuranceNavigation: View {
    let configs: [InsuredPeopleConfig]
    @StateObject var router = Router()
    @StateObject private var editCoInsuredSelectInsuranceNavigationVm =
        EditCoInsuredSelectInsuranceNavigationViewModel()
    private var checkForAlert: () -> Void

    public init(
        configs: [InsuredPeopleConfig],
        checkForAlert: @escaping () -> Void
    ) {
        self.configs = configs
        self.checkForAlert = checkForAlert
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large)) {
            openSelectInsurance()
        }
        .fullScreenCover(
            item: $editCoInsuredSelectInsuranceNavigationVm.editCoInsuredConfig
        ) { config in
            EditCoInsuredNavigation(config: config, checkForAlert: checkForAlert)
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
            onSelected: { selectedConfigs in
                if let selectedConfig = selectedConfigs.first {
                    if let object = selectedConfig.0 {
                        editCoInsuredSelectInsuranceNavigationVm.editCoInsuredConfig = object
                        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                        store.coInsuredViewModel.initializeCoInsured(with: object)
                    }
                }
            },
            onCancel: {
                router.dismiss()
            },
            singleSelect: true,
            hButtonText: L10n.generalContinueButton
        )
        .configureTitle(L10n.SelectInsurance.NavigationBar.CenterElement.title)
    }
}

public class EditCoInsuredAlertNavigationViewModel: ObservableObject {
    @Published var editCoInsuredConfig: InsuredPeopleConfig?
}

public struct EditCoInsuredAlertNavigation: View {
    let config: InsuredPeopleConfig
    @StateObject var router = Router()
    @StateObject private var editCoInsuredAlertNavigationVm = EditCoInsuredAlertNavigationViewModel()
    private var checkForAlert: () -> Void

    public init(
        config: InsuredPeopleConfig,
        checkForAlert: @escaping () -> Void
    ) {
        self.config = config
        self.checkForAlert = checkForAlert
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large)) {
            openMissingCoInsuredAlert()
        }
        .fullScreenCover(item: $editCoInsuredAlertNavigationVm.editCoInsuredConfig) { config in
            EditCoInsuredNavigation(
                config: config,
                openSpecificScreen: .newInsurance,
                checkForAlert: {
                    checkForAlert()
                }
            )
        }
    }

    public func openMissingCoInsuredAlert() -> some View {
        return MissingCoInsuredAlert(onButtonAction: {
            let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
            editCoInsuredAlertNavigationVm.editCoInsuredConfig = store.coInsuredViewModel.config
        })
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

public struct CoInsuredInputModel: Identifiable, Equatable {
    public var id: String?
    let actionType: CoInsuredAction
    let coInsuredModel: CoInsuredModel
    let title: String
    let contractId: String
}

public struct SelectCoInsured: Identifiable, Equatable {
    public var id: String
}
