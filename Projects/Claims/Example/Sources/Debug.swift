import Flow
import Foundation
import Presentation

struct Debug {}

extension Debug: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = "ClaimsExample"

        return (viewController, bag)
    }
}
