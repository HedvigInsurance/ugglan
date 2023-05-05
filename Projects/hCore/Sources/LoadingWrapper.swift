public enum LoadingWrapper<T, E>: Codable, Equatable, Hashable
where T: Codable & Equatable & Hashable, E: Codable & Equatable & Hashable {
    case loading
    case success(T)
    case error(E)

    public func getData() -> T? {
        switch self {
        case .loading:
            return nil
        case let .success(t):
            return t
        case .error:
            return nil
        }
    }
}
