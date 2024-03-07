import Flow
import Foundation
import Presentation
import SwiftUI

struct Debug {}

extension Debug: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = "ClaimsExample"

        return (viewController, bag)
    }
}
