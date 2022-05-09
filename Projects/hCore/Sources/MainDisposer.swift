import Foundation
import Flow

public struct DisposeOnMain: Disposable {
    var disposable: Disposable
    
    public init(_ disposable: Disposable) {
        self.disposable = disposable
    }
    
    public func dispose() {
        DispatchQueue.main.async {
            disposable.dispose()
        }
    }
}
