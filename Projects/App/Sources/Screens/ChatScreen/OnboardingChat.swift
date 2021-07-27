import Apollo
import Flow
import Form
import Presentation
import UIKit
import hCore

struct OnboardingChat { @Inject var client: ApolloClient }

enum OnboardingChatResult {
    case menu(action: MenuChildAction)
}

extension OnboardingChat: Presentable {
	func materialize() -> (UIViewController, Signal<OnboardingChatResult>) {
		let bag = DisposeBag()

		ApplicationState.preserveState(.onboardingChat)

		let chat = Chat()
		let (viewController, future) = chat.materialize()
		viewController.navigationItem.hidesBackButton = true

		chat.chatState.fetch()

		let settingsButton = UIBarButtonItem()
		settingsButton.image = Asset.menuIcon.image
		settingsButton.tintColor = .brand(.primaryText())

		viewController.navigationItem.leftBarButtonItem = settingsButton

		let restartButton = UIBarButtonItem()
		restartButton.image = Asset.restart.image
		restartButton.tintColor = .brand(.primaryText())

		bag += restartButton.onValue { _ in
			let alert = Alert(
				title: L10n.chatRestartAlertTitle,
				message: L10n.chatRestartAlertMessage,
				actions: [
					Alert.Action(
						title: L10n.chatRestartAlertConfirm,
						action: { chat.reloadChatCallbacker.callAll() }
					), Alert.Action(title: L10n.chatRestartAlertCancel, action: {}),
				]
			)

			viewController.present(alert)
		}

		viewController.navigationItem.rightBarButtonItem = restartButton

		viewController.navigationItem.titleView = .titleWordmarkView

		bag += future.onValue { _ in }

        return (viewController, Signal { callback in
            bag += settingsButton.attachSinglePressMenu(
                viewController: viewController,
                menu: Menu(
                    title: nil,
                    children: [
                        MenuChild.appInformation,
                        MenuChild.appSettings,
                        MenuChild.login
                    ]
                )
            ) { action in
                callback(.menu(action: action))
            }
            
            return bag
        })
	}
}
