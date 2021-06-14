import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore

struct StartDate: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = L10n.offerSetStartDate
		let bag = DisposeBag()

		let form = FormView()
		bag += viewController.install(form)
		bag += form.append(SingleStartDateSection(title: "Home contents"))

		return (viewController, bag)
	}
}
