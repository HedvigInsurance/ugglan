public enum LoadingWrapper<T, E>: Codable, Equatable where T: Codable & Equatable, E: Codable & Equatable {
    case loading
    case success(T)
    case error(E)
}
