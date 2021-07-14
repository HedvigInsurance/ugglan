import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct EmbarkAddressAutocomplete: AddressTransitionable {
    var boxFrame: ReadWriteSignal<CGRect?> = ReadWriteSignal(CGRect.zero)
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
		bag += viewController.install(form, options: [], scrollView: scrollView)
        
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        
        form.append(view)
        
        let addressAutocompleteAction = EmbarkAddressAutocompleteAction(
            state: self.state,
            data: self.data
        )
        
        bag += addressAutocompleteAction.boxFrame.bindTo(boxFrame)

        bag += view.didMoveToWindowSignal.delay(by: 0.7).onValue { _ in
            print("FRAME WINDOW MOVED")
            bag += view.addArranged(addressAutocompleteAction)
        }
        
		//        let textField = UITextField()
		//        textField.autocorrectionType = .no
		//        form.append(textField)
		//        textField.becomeFirstResponder()

		return (viewController, bag)
	}
}
