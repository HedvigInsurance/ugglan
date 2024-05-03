import Presentation
import SwiftUI

public indirect enum ForeverAction: ActionProtocol {
    case showChangeCodeSuccess
    case dismissChangeCodeDetail
    case fetch
    case setForeverData(data: ForeverData)
}

public enum ForeverLoadingType: LoadingProtocol {
    case fetchForeverData
}
