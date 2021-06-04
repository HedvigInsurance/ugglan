import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

struct StartDate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.offerSetStartDate
        let bag = DisposeBag()

        let form = FormView()
        bag += viewController.install(form)

        return (viewController, bag)
    }
}
