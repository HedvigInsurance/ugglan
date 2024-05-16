import Presentation
import SwiftUI

public indirect enum ForeverAction: ActionProtocol {
    case showChangeCodeDetail
    case showChangeCodeSuccess
    case dismissChangeCodeDetail
    case fetch
    case setForeverData(data: ForeverData)
    case showInfoSheet(discount: String)
    case closeInfoSheet
    case showShareSheetOnly(code: String, discount: String)

    case setForeverDataMissing(isMissing: Bool)
}

public enum ForeverLoadingType: LoadingProtocol {
    case fetchForeverData
}
