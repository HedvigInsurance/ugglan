import Foundation

public enum ProcessingState: Equatable {
    case loading
    case success
    case error(errorMessage: String)

    public var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
}
