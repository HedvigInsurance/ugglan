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

    @Published var externalNavigationRedirect = NavigationPath()
}

public enum EditCoInsuredScreenType {
    case missingAlert
    case newInsurance
    case none
}

public struct EditCoInsuredNavigation: View {
    let configs: [InsuredPeopleConfig]
    @State var openSpecificScreen: EditCoInsuredScreenType
    @StateObject private var editCoInsuredNavigationVm = EditCoInsuredNavigationViewModel()
    @StateObject var router = Router()

    public init(
        configs: [InsuredPeopleConfig],
        openSpecificScreen: EditCoInsuredScreenType? = EditCoInsuredScreenType.none
    ) {
        self.configs = configs
        self.openSpecificScreen = openSpecificScreen ?? .none

        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        if let config = editCoInsuredNavigationVm.editCoInsuredConfig {
            store.coInsuredViewModel.initializeCoInsured(with: config)
        } else if let config = configs.first {
            store.coInsuredViewModel.initializeCoInsured(with: config)
        }
    }

    public var body: some View {
        RouterHost(router: router) {
            if openSpecificScreen == .missingAlert {
                openMissingCoInsuredAlert()
            } else if openSpecificScreen == .newInsurance {
                openNewInsuredPeopleScreen()
            } else if openSpecificScreen == .none {
                if configs.count > 1 {
                    openSelectInsurance(configs: configs)
                } else if let config = configs.first {
                    if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                        if config.fromInfoCard {
                            openNewInsuredPeopleScreen()
                        } else {
                            openRemoveCoInsuredScreen()
                        }
                    } else if configs.first?.numberOfMissingCoInsuredWithoutTermination ?? 0 > 0 {
                        openNewInsuredPeopleScreen()
                    } else {
                        openInsuredPeopleScreen()
                    }
                }
            }
        }
        .fullScreenCover(item: $editCoInsuredNavigationVm.editCoInsuredConfig) { config in
            Group {
                if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                    openNewInsuredPeopleScreen()
                } else {
                    openInsuredPeopleScreen()
                }
            }
            .detent(
                item: $editCoInsuredNavigationVm.coInsuredInputModel,
                style: .height
            ) { coInsuredInputModel in
                coInsuredInput(coInsuredInputModel: coInsuredInputModel)
            }
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

    func openSelectInsurance(configs: [InsuredPeopleConfig]) -> some View {
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
                        editCoInsuredNavigationVm.editCoInsuredConfig = object
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

    public func openMissingCoInsuredAlert() -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        return GenericErrorView(
            title: store.coInsuredViewModel.config.contractDisplayName,
            description: L10n.contractCoinsuredMissingInformationLabel,
            buttons: .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                        buttonAction: {
                            openSpecificScreen = .newInsurance
                            editCoInsuredNavigationVm.editCoInsuredConfig = store.coInsuredViewModel.config
                        }
                    ),
                dismissButton:
                    .init(
                        buttonTitle: L10n.contractCoinsuredMissingLater,
                        buttonAction: {
                            router.dismiss()
                        }
                    )
            )
        )
        .hExtraBottomPadding
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
