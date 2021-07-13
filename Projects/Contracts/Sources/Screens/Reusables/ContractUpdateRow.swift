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
		let view = UIView()
		let bag = DisposeBag()

		return (
			view,
			{ `self` in

				return bag
			}
		)
	}
}
