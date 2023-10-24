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
            if case let .openCoInsuredInput(isDeletion, name, personalNumber, title) = navigationAction {
                openCoInsuredInput(isDeletion: isDeletion, name: name, personalNumber: personalNumber, title: title).withJourneyDismissButton
            } else if case .dismissEditCoInsuredFlow = navigationAction {
                DismissJourney()
            } else if case let .openCoInsuredProcessScreen(showSuccess) = navigationAction {
                openProgress(showSuccess: showSuccess)
            }
        }
    }

    @JourneyBuilder
    public static func openInsuredPeopleScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleScreen(),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
        .withJourneyDismissButton
    }
    
    @JourneyBuilder
    public static func openNewInsuredPeopleNewScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleNewScreen(),
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
        title: String
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInusuredInput(isDeletion: isDeletion, name: name, personalNumber: personalNumber),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .coInsuredNavigationAction(.dismissEdit) = action {
                PopJourney()
            } else if case .addLocalCoInsured = action {
                PopJourney()
            } else if case .removeLocalCoInsured = action {
                PopJourney()
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

}
