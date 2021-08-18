import Flow
import Foundation

public func += (disposeBag: DisposeBag, disposableArray: [Disposable?]?) {
    guard let disposableArray = disposableArray else { return }
    disposableArray.compactMap { $0 }.forEach { disposeBag.add($0) }
}
