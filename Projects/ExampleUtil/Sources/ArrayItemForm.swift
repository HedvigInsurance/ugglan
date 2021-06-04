import Flow
import Form
import Foundation
import Presentation
import Runtime
import UIKit
import hCore
import hCoreUI

struct ArrayItemForm: Presentable {
	let item: AnyCodable
	let type: Any.Type
	let isEditing: Bool

	func materialize() -> (UIViewController, Future<AnyCodable>) {
		let viewController = UIViewController()
		viewController.extendedLayoutIncludesOpaqueBars = true
		viewController.title = isEditing ? "Editing" : "Create new"

		let bag = DisposeBag()
		let form = FormView()

		var itemCopy = item

		if let info = try? typeInfo(of: type) {
			bag += info.properties.map { property in
				let (section, bag) = getSection(for: property, typeInstance: item, in: viewController) {
					value in try? property.set(value: value, on: &itemCopy)
				}

				form.append(section)

				return bag
			}
		}

		let button = Button(
			title: "Save",
			type: .standard(
				backgroundColor: .brand(.primaryButtonBackgroundColor),
				textColor: .brand(.primaryButtonTextColor)
			)
		)
		bag += form.append(button)

		bag += viewController.install(form) { scrollView in
			bag += scrollView.chainAllControlResponders(shouldLoop: false, returnKey: .next)
		}

		return (
			viewController,
			Future<AnyCodable> { completion in
				bag += button.onTapSignal.onValue { completion(.success(itemCopy)) }

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
