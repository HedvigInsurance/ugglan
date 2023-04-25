public enum LoadingWrapper<T, E>: Codable, Equatable, Hashable
where T: Codable & Equatable & Hashable, E: Codable & Equatable & Hashable {
    case loading
    case success(T)
    case error(E)
}
