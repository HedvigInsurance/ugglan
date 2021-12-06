import Flow
import Form
import Foundation
import UIKit

public enum SpacingType {
    case top
    case inbetween
    case custom(_ height: CGFloat)

    public var height: CGFloat {
        switch self {
        case let .custom(height): return height
        case .top: return 40
        case .inbetween: return 16
        }
    }
}

extension SubviewOrderable {
    public func appendSpacing(_ type: SpacingType) {
        let view = UIView()

        view.snp.makeConstraints { make in make.height.equalTo(type.height) }

        append(view)
    }

    public func appendSpacingAndDumpOnDispose(_ type: SpacingType) -> Disposable {
        let view = UIView()

        view.snp.makeConstraints { make in make.height.equalTo(type.height) }

        append(view)

        let disposable = DisposeBag()

        disposable += {
            view.removeFromSuperview()
        }

        return disposable
    }
}
