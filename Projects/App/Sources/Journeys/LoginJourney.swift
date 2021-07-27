import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct LoginJourney {
	static var bankIDSweden: some JourneyPresentation {
		Journey(
			BankIDLoginSweden(),
			style: .detented(.medium, .large)
		) { result in
			switch result {
			case .qrCode:
				Journey(BankIDLoginQR()) { result in
					switch result {
					case .loggedIn:
						MainTabbedJourney.journey
					}
				}
			case .loggedIn:
				MainTabbedJourney.journey
			}
		}
		.withDismissButton
	}

	static var simpleSign: some JourneyPresentation {
		Journey(SimpleSignLoginView(), style: .detented(.medium)) { id in
			Journey(WebViewLogin(idNumber: id), style: .detented(.large))
		}
		.withDismissButton
	}

	static var journey: some JourneyPresentation {
		MarketGroupJourney { market in
			switch market {
			case .se:
				bankIDSweden
			case .no, .dk:
				simpleSign
			}
		}
	}
}

extension MenuChildAction {
	static var login: MenuChildAction {
		MenuChildAction(identifier: "login")
	}
}

extension MenuChild {
	public static var login: MenuChild {
		MenuChild(
			title: L10n.settingsLoginRow,
			style: .default,
			image: hCoreUIAssets.memberCard.image,
			action: .login
		)
	}
}
