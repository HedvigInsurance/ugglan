import Flow
import Foundation

extension Flow.Result {
    func isSuccess() -> Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}
