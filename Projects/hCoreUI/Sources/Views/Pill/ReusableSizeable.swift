import Flow
import Form
import Foundation
import UIKit

protocol ReusableSizeable: Reusable {
    var size: CGSize { get }
}

extension ReusableSizeable where ReuseType: UIView {
    var size: CGSize {
        let (view, configure) = Self.makeAndConfigure()

        let bag = DisposeBag()
        bag += configure(self)

        let size = view.systemLayoutSizeFitting(.zero)

        bag.dispose()

        return size
    }
}
