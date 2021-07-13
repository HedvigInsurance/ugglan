import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct ContractUpdateRow {

}

extension ContractUpdateRow: Reusable {
	static func makeAndConfigure() -> (make: UIView, configure: (ContractUpdateRow) -> Disposable) {
		let cardView = UIView()
		let bag = DisposeBag()

		return (
			cardView,
			{ `self` in

				return bag
			}
		)
	}
}
