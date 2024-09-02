import PresentableStore
import SwiftUI

public indirect enum ForeverAction: ActionProtocol {
    case fetch
    case setForeverData(data: ForeverData)
}

public enum ForeverLoadingType: LoadingProtocol {
    case fetchForeverData
}
