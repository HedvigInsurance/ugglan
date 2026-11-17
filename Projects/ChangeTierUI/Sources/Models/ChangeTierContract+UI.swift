import ChangeTierCore
import hCoreUI

extension ChangeTierContract: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: ChangeTierContract.self)
    }
}
