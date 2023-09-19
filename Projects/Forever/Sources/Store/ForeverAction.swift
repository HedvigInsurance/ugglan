import Presentation
import SwiftUI

public indirect enum ForeverAction: ActionProtocol {
    case hasSeenFebruaryCampaign(value: Bool)
    case showChangeCodeDetail
    case showChangeCodeSuccess
    case dismissChangeCodeDetail
    case fetch
    case setForeverData(data: ForeverData)
    case showInfoSheet(discount: String)
    case closeInfoSheet
    case showShareSheetOnly(code: String, discount: String)
}

public enum ForeverLoadingType: LoadingProtocol {
    case fetchForeverData
}
