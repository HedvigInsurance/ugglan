import Foundation
import Presentation
import hAnalytics
import hCore
import hCoreUI

public class EditCoInsuredJourney {
    @JourneyBuilder
    public static func getScreenForAction(
        for action: ContractAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getScreen(for: action).hidesBackButton
        } else {
            getScreen(for: action).showsBackButton
        }
    }
    
    @JourneyBuilder
    private static func getScreen(for action: ContractAction) -> some JourneyPresentation {
        if case let .coInsuredNavigationAction(navigationAction) = action {
            if case let .openInsuredPeopleScreen(contractId) = navigationAction {
                openInsuredPeopleScreen(id: contractId).withJourneyDismissButton
            } else if case let .openInsuredPeopleNewScreen(contractId) = navigationAction {
                openNewInsuredPeopleScreen(id: contractId).withJourneyDismissButton
            } else if case let .openCoInsuredInput(isDeletion, name, personalNumber, title, contractId) = navigationAction {
                openCoInsuredInput(isDeletion: isDeletion, name: name, personalNumber: personalNumber, title: title, contractId: contractId).withJourneyDismissButton
            } else if case .dismissEditCoInsuredFlow = navigationAction {
                DismissJourney()
            } else if case let .openCoInsuredProcessScreen(showSuccess) = navigationAction {
                openProgress(showSuccess: showSuccess).hidesBackButton
            }
        }
    }
    
    @JourneyBuilder
    public static func openInsuredPeopleScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleScreen(contractId: id),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
        .withJourneyDismissButton
    }
    
    @JourneyBuilder
    public static func openNewInsuredPeopleScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleNewScreen(contractId: id),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
        .withJourneyDismissButton
    }
    
    @JourneyBuilder
    public static func openCoInsuredInput(
        isDeletion: Bool,
        name: String?,
        personalNumber: String?,
        title: String,
        contractId: String
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInusuredInput(isDeletion: isDeletion, name: name, personalNumber: personalNumber, contractId: contractId),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .coInsuredNavigationAction(.dismissEdit) = action {
                PopJourney()
//            } else if case .addLocalCoInsured = action {
//                PopJourney()
//            } else if case .removeLocalCoInsured = action {
//                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .configureTitle(title)
    }
    
    @JourneyBuilder
    public static func openProgress(showSuccess: Bool) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredProcessingScreen(showSuccessScreen: showSuccess)
        ) { action in
            getScreen(for: action)
        }
    }
    
    @JourneyBuilder
    public static func openSelectInsurance(contractIds: [String]) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CheckboxPickerScreen<Contract>(
                items: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let contracts: [Contract] = contractIds.compactMap { id in
                        contractStore.state.contractForId(id)
                    }
                    return contracts.compactMap({ (object: $0, displayName: $0.currentAgreement?.productVariant.displayName ?? "") })
                }(),
                preSelectedItems: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let preSelectedItem = contractStore.state.contractForId(contractIds.first ?? "")
                    if let preSelectedItem {
                        return [preSelectedItem]
                    }
                    else {
                        return []
                    }
                },
                onSelected: { selectedContract in
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.send(.coInsuredNavigationAction(action: .openInsuredPeopleNewScreen(contractId: selectedContract.first?.id ?? "")))
                },
                singleSelect: true
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            getScreen(for: action)
        }
    }
}
