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
                openCoInsuredInput(isDeletion: isDeletion, name: name, personalNumber: personalNumber, title: title)
            } else if case .dismissEditCoInsuredFlow = navigationAction {
                DismissJourney()
            } else if case .openCoInsuredProcessScreen = navigationAction {
                openProgress()
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
    public static func openProgress() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredProcessingScreen()
                //            style: .modally(presentationStyle: .overFullScreen),
                //            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
    }

}
