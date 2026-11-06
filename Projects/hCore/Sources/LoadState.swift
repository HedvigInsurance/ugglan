import Foundation

public enum LoadState<Value> {
    case notLoaded
    case loading
    case loaded(Value)
    case failed(errorMessage: String)

    public var value: Value? {
        if case let .loaded(value) = self { return value }
        return nil
    }

    public var needsLoading: Bool {
        switch self {
        case .notLoaded, .failed: true
        case .loading, .loaded: false
        }
    }

    public var processingState: ProcessingState {
        switch self {
        case .notLoaded, .loading: .loading
        case .loaded: .success
        case let .failed(errorMessage): .error(errorMessage: errorMessage)
        }
    }
}

extension LoadState: Equatable where Value: Equatable {}
extension LoadState: Sendable where Value: Sendable {}
