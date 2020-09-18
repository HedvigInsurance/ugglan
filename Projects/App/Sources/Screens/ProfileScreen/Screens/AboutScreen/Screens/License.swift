// import AcknowList
import Flow
import Foundation
import Presentation
import UIKit

struct License {}

extension License: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: 500)

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .brand(.primaryBackground())
        scrollView.alwaysBounceVertical = true

        viewController.view = scrollView

        return (viewController, bag)
    }
}
