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
    @Published var showSuccessScreen: CoInsuredAction?

    @Published var externalNavigationRedirect = NavigationPath()
}

public struct EditCoInsuredViewJourney: View {
    let configs: [InsuredPeopleConfig]
    let onDisappear: () -> Void
    @StateObject private var editCoInsuredNavigationVm = EditCoInsuredNavigationViewModel()

    public init(
        configs: [InsuredPeopleConfig],
        onDisappear: @escaping () -> Void
    ) {
        self.configs = configs
        self.onDisappear = onDisappear
    }

    public var body: some View {
        NavigationStack(path: $editCoInsuredNavigationVm.externalNavigationRedirect) {
            Group {
                if configs.count > 1 {
                    openSelectInsurance(configs: configs)
                        .fullScreenCover(item: $editCoInsuredNavigationVm.editCoInsuredConfig) { config in
                            Group {
                                if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                                    openNewInsuredPeopleScreen()
                                } else {
                                    openInsuredPeopleScreen()
                                }
                            }
                            .sheet(item: $editCoInsuredNavigationVm.coInsuredInputModel) { coInsuredInputModel in
                                openCoInsuredInput(coInsuredModelEdit: coInsuredInputModel)
                                    .presentationDetents([.medium])
                            }
                        }
                } else if let config = configs.first {
                    if config.numberOfMissingCoInsuredWithoutTermination > 0 {
                        if config.fromInfoCard {
                            openNewInsuredPeopleScreen()
                        } else {
                            openRemoveCoInsuredScreen(config: config)
                        }
                    } else if configs.first?.numberOfMissingCoInsuredWithoutTermination ?? 0 > 0 {
                        openNewInsuredPeopleScreen()
                    } else {
                        openInsuredPeopleScreen()
                    }
                }
            }
            .sheet(item: $editCoInsuredNavigationVm.coInsuredInputModel) { coInsuredInputModel in
                openCoInsuredInput(coInsuredModelEdit: coInsuredInputModel)
                    .presentationDetents([.medium])
            }
            .sheet(item: $editCoInsuredNavigationVm.selectCoInsured) { selectCoInsured in
                openCoInsuredSelectScreen(contractId: selectCoInsured.id)
                    .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $editCoInsuredNavigationVm.showProgressScreenWithSuccess) {
                openProgress(showSuccess: true)
            }
            .fullScreenCover(isPresented: $editCoInsuredNavigationVm.showProgressScreenWithoutSuccess) {
                openProgress(showSuccess: false)
            }
            .sheet(item: $editCoInsuredNavigationVm.showSuccessScreen) { actionType in
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
            .environmentObject(editCoInsuredNavigationVm)
        }
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
                onDisappear()
            },
            singleSelect: true,
            hButtonText: L10n.generalContinueButton
        )
    }

    func openNewInsuredPeopleScreen() -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        if let config = editCoInsuredNavigationVm.editCoInsuredConfig {
            store.coInsuredViewModel.config = config
        } else if let config = configs.first {
            store.coInsuredViewModel.config = config
        }

        return InsuredPeopleNewScreen(
            vm: store.coInsuredViewModel,
            intentVm: store.intentViewModel,
            onDisappear: {
                onDisappear()
            }
        )
    }

    func openInsuredPeopleScreen() -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        if let config = editCoInsuredNavigationVm.editCoInsuredConfig {
            store.coInsuredViewModel.config = config
        } else if let config = configs.first {
            store.coInsuredViewModel.config = config
        }
        return InsuredPeopleScreen(
            vm: store.coInsuredViewModel,
            intentVm: store.intentViewModel,
            onDisappear: {
                onDisappear()
            }
        )
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
    }

    func openCoInsuredSelectScreen(contractId: String) -> some View {
        CoInsuredSelectScreen(contractId: contractId)
    }

    func openProgress(showSuccess: Bool) -> some View {
        CoInsuredProcessingScreen(showSuccessScreen: showSuccess)
    }

    func openSuccessScreen(title: String) -> some View {
        SuccessScreen(title: title)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    editCoInsuredNavigationVm.showSuccessScreen = nil
                }
            }
            .presentationDetents([.medium])
    }

    func openRemoveCoInsuredScreen(config: InsuredPeopleConfig) -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.initializeCoInsured(with: config)
        return RemoveCoInsuredScreen(
            vm: store.coInsuredViewModel,
            onDisappear: {
                onDisappear()
            }
        )
    }
}

//public class EditCoInsuredJourney {
//    @JourneyBuilder
//    private static func getScreen(for action: EditCoInsuredAction) -> some JourneyPresentation {
//        if case let .coInsuredNavigationAction(navigationAction) = action {
//            if case let .openInsuredPeopleScreen(config) = navigationAction {
//                openInsuredPeopleScreen(with: config)
//            } else if case let .openInsuredPeopleNewScreen(config) = navigationAction {
//                openNewInsuredPeopleScreen(config: config)
//            } else if case let .openCoInsuredInput(actionType, coInsuredModel, title, contractId) = navigationAction {
//                openCoInsuredInput(
//                    actionType: actionType,
//                    coInsuredModel: coInsuredModel,
//                    title: title,
//                    contractId: contractId,
//                    style: .detented(.scrollViewContentSize)
//                )
//            } else if case .dismissEditCoInsuredFlow = navigationAction {
//                DismissJourney()
//            } else if case let .openCoInsuredProcessScreen(showSuccess) = navigationAction {
//                openProgress(showSuccess: showSuccess).hidesBackButton
//            } else if case let .openCoInsuredSelectScreen(contractId) = navigationAction {
//                openCoInsuredSelectScreen(contractId: contractId)
//            } else if case let .openMissingCoInsuredAlert(config) = navigationAction {
//                openMissingCoInsuredAlert(config: config)
//            } else if case let .openSelectInsuranceScreen(configs) = navigationAction {
//                openSelectInsurance(configs: configs)
//            }
//        }
//    }

//    static func openRemoveCoInsuredScreen(config: InsuredPeopleConfig) -> some JourneyPresentation {
//        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
//        store.coInsuredViewModel.initializeCoInsured(with: config)
//
//        return HostingJourney(
//            EditCoInsuredStore.self,
//            rootView: RemoveCoInsuredScreen(vm: store.coInsuredViewModel),
//            style: .modally(presentationStyle: .overFullScreen),
//            options: [.defaults, .withAdditionalSpaceForProgressBar]
//        ) { action in
//            getScreen(for: action)
//        }
//        .configureTitle(L10n.coinsuredEditTitle)
//    }

//    @JourneyBuilder
//    public static func openMissingCoInsuredAlert(config: InsuredPeopleConfig) -> some JourneyPresentation {
//        HostingJourney(
//            EditCoInsuredStore.self,
//            rootView: GenericErrorView(
//                title: config.contractDisplayName,
//                description: L10n.contractCoinsuredMissingInformationLabel,
//                buttons: .init(
//                    actionButtonAttachedToBottom:
//                        .init(
//                            buttonTitle: L10n.contractCoinsuredMissingAddInfo,
//                            buttonAction: {
//                                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
//                                store.send(.coInsuredNavigationAction(action: .dismissEdit))
//                                store.send(.openEditCoInsured(config: config, fromInfoCard: true))
//                            }
//                        ),
//                    dismissButton:
//                        .init(
//                            buttonTitle: L10n.contractCoinsuredMissingLater,
//                            buttonAction: {
//                                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
//                                store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
//                            }
//                        )
//                )
//            )
//            .hExtraBottomPadding,
//
//            style: .detented(.scrollViewContentSize),
//            options: [.largeNavigationBar, .blurredBackground]
//        ) { action in
//            getScreen(for: action)
//        }
//        .onAction(EditCoInsuredStore.self) { action in
//            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
//                PopJourney()
//            } else {
//                getScreen(for: action)
//            }
//        }
//    }

//    @JourneyBuilder
//    public static func handleOpenEditCoInsured(
//        for config: InsuredPeopleConfig,
//        fromInfoCard: Bool
//    ) -> some JourneyPresentation {
//        if config.numberOfMissingCoInsuredWithoutTermination > 0 {
//            if fromInfoCard {
//                EditCoInsuredJourney.openNewInsuredPeopleScreen(config: config)
//            } else {
//                EditCoInsuredJourney.openRemoveCoInsuredScreen(config: config)
//            }
//        } else {
//            EditCoInsuredJourney.openInsuredPeopleScreen(with: config)
//        }
//    }
//}
//
//extension JourneyPresentation {
//    func addDismissEditCoInsuredFlow() -> some JourneyPresentation {
//        self.withJourneyDismissButtonWithConfirmation(
//            withTitle: L10n.General.areYouSure,
//            andBody: L10n.Claims.Alert.body,
//            andCancelText: L10n.General.no,
//            andConfirmText: L10n.General.yes
//        )
//    }
//}

public struct CoInsuredInputModel: Identifiable {
    public var id: String?
    let actionType: CoInsuredAction
    let coInsuredModel: CoInsuredModel
    let title: String
    let contractId: String
}

public struct SelectCoInsured: Identifiable {
    public var id: String
}
