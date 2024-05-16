import Foundation
import Presentation

public struct ForeverState: StateProtocol {
    public init() {}
    public var foreverData: ForeverData? = nil
    public var isForeverDataMissing: Bool = true
}
