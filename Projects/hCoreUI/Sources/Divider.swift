import Flow
import Foundation
import hCore
import UIKit

public struct Divider {
    public let backgroundColor: UIColor

    public init(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
}

extension Divider: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let divider = UIView()

        let bag = DisposeBag()

        divider.backgroundColor = backgroundColor

        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        return (divider, bag)
    }
}
