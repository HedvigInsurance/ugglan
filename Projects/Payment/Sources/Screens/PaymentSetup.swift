import Flow
import Foundation
import Presentation
import UIKit
import hCore

public struct PaymentSetup {
	let setupType: SetupType
	let urlScheme: String

	public enum SetupType { case initial, replacement, postOnboarding }

	public init(
		setupType: SetupType,
		urlScheme: String
	) {
		self.setupType = setupType
		self.urlScheme = urlScheme
	}
}

extension PaymentSetup: Presentable {
	public func materialize() -> (UIViewController, Future<Void>) {
		switch Localization.Locale.currentLocale.market {
		case .se: return DirectDebitSetup(setupType: setupType).materialize()
		case .no, .dk: return AdyenPayInSync(urlScheme: urlScheme).materialize()
		}
	}
}
