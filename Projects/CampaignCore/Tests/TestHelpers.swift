import Testing

@MainActor
func assertDeallocates<T: AnyObject>(
    _ make: () -> T,
    perform: (T) async throws -> Void
) async rethrows {
    weak var ref: T?
    do {
        let object = make()
        ref = object
        try await perform(object)
    }
    #expect(ref == nil, "Expected \(T.self) to be deallocated")
}
