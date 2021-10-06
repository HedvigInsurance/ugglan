import Flow
import Foundation

extension Array where Element: Disposable {
    public var disposable: Disposable {
        DisposeBag(self)
    }
}
