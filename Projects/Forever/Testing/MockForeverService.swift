import Flow
import Forever

public struct MockForeverService: ForeverService {
    let data: ForeverData
    public var dataSignal: ReadSignal<ForeverData> {
        .init(data)
    }

    public func refetch() {}

    public init(data: ForeverData) {
        self.data = data
    }
}
