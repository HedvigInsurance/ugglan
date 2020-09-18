import Flow
import Foundation
import hCore
import UIKit

struct TooltipButton {
    let state: EmbarkState
}

extension TooltipButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UILabel(value: "fish", style: .brand(.body(color: .primary)))
        let bag = DisposeBag()

        return (view, bag)
    }
}
