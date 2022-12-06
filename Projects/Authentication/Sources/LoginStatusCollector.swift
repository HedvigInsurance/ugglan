import Foundation
import authlib

class LoginStatusCollector: Kotlinx_coroutines_coreFlowCollector {
    var onResult: (_ result: LoginStatusResult) -> Void
    
    init(onResult: @escaping (_ result: LoginStatusResult) -> Void) {
        self.onResult = onResult
    }
    
    func emit(value: Any?, completionHandler: @escaping (Error?) -> Void) {
        print(value)
        if let result = value as? LoginStatusResult {
            onResult(result)
        }
    }
}
