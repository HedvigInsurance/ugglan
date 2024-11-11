import PresentableStore
import SwiftUI
import hCore

public indirect enum SubmitClaimsAction: ActionProtocol, Hashable {
    case setProgress(progress: Float?)
    case setOnlyProgress(progress: Float?)
    case setOnlyPreviousProgress(progress: Float?)
}

public enum SubmitAudioRecordingType: ActionProtocol, Hashable {
    case audio(url: URL)
    case text(text: String)
}

public enum ClaimsLoadingType: LoadingProtocol {
    case postPhoneNumber
}
