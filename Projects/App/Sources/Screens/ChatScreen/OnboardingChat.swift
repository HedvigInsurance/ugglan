import Apollo
import Flow
import Form
import Presentation
import UIKit
import hCore

struct OnboardingChat { @Inject var client: ApolloClient }

enum OnboardingChatResult {
	case menu(action: MenuChildAction)
	case chat(result: ChatResult)

	var journey: some JourneyPresentation {
		GroupJourney {
			switch self {
			case let .menu(action):
				action.journey
			case let .chat(result):
				result.journey
			}
		}
	}
}

extension OnboardingChat: Presentable {
	func materialize() -> (UIViewController, Signal<OnboardingChatResult>) {
		let bag = DisposeBag()

		ApplicationState.preserveState(.onboardingChat)

		let chat = Chat()
		let (viewController, signal) = chat.materialize()
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

		return (
			viewController,
			Signal { callback in
				bag += settingsButton.attachSinglePressMenu(
					viewController: viewController,
					menu: Menu(
						title: nil,
						children: [
							MenuChild.appInformation,
							MenuChild.appSettings,
							MenuChild.login,
						]
					)
				) { action in
					callback(.menu(action: action))
				}

				bag += signal.onValue { result in
					callback(.chat(result: result))
				}

				return bag
			}
		)
	}
}
