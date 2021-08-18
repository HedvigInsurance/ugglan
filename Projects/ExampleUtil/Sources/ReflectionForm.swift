import Flow
import Form
import Foundation
import Presentation
import Runtime
import UIKit
import hCore
import hCoreUI

struct ReflectionForm<T: Codable> {
    let editInstance: T?
    let title: String
}

extension ReflectionForm: Presentable {
    func materialize() -> (UIViewController, Future<T>) {
        let viewController = UIViewController()
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.title = "Create new"

        let bag = DisposeBag()
        let form = FormView()

        guard var typeInstance = editInstance ?? (try? createInstance(of: T.self) as? T) else {
            fatalError("Couldn't create instance of type \(T.self)")
        }

        if let info = try? typeInfo(of: T.self) {
            bag += info.properties.map { property in
                let (section, bag) = getSection(
                    for: property,
                    typeInstance: typeInstance,
                    in: viewController
                ) { value in try? property.set(value: value, on: &typeInstance) }

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
            Future<T> { completion in
                bag += button.onTapSignal.onValue {
                    if self.editInstance == nil {
                        ReflectionFormHistory<T>(title: self.title).appendItem(typeInstance)
                    }
                    completion(.success(typeInstance))
                }

                return DelayedDisposer(bag, delay: 2)
            }
        )
    }
}
