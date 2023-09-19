import Foundation
import Presentation

public struct ForeverState: StateProtocol {
    public var hasSeenFebruaryCampaign: Bool {
        didSet {
            UserDefaults.standard.synchronize()
        }
    }

    public init() {
        self.hasSeenFebruaryCampaign = false
    }

    public var foreverData: ForeverData? = nil
}
