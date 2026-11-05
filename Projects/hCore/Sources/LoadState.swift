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

    /// True when a load should start: nothing has loaded yet (or the last attempt failed) and none is in flight.
    public var needsLoading: Bool {
        switch self {
        case .notLoaded, .failed: true
        case .loading, .loaded: false
        }
    }

    /// For screens using `.loading(_:)`; a value that hasn't started loading yet shows as loading.
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
