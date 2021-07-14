import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct EmbarkAddressAutocomplete {
	let state: EmbarkState
	let data: EmbarkAddressAutocompleteData
}

extension EmbarkAddressAutocomplete: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = "Address"
		let bag = DisposeBag()

		let scrollView = FormScrollView()
		let form = FormView()

		let addressAutocompleteAction = EmbarkAddressAutocompleteAction(
			state: self.state,
			data: self.data
		)
		bag += form.append(addressAutocompleteAction)

		bag += viewController.install(form, options: [], scrollView: scrollView)

		//        let textField = UITextField()
		//        textField.autocorrectionType = .no
		//        form.append(textField)
		//        textField.becomeFirstResponder()

		return (viewController, bag)
	}
}
