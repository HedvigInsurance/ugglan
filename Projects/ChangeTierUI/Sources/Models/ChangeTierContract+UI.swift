import ChangeTierCore
import hCoreUI

extension ChangeTierContract: @retroactive TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: ChangeTierContract.self)
    }
}
