import Apollo
import Presentation
import SwiftUI
import hCore
import hGraphQL

public indirect enum ClaimsAction: ActionProtocol, Hashable {
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [ClaimModel])
    case setFiles(files: [String: [File]])
    case openFreeTextChat
    case openClaimDetails(claim: ClaimModel)
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case closeClaimStatus
    case navigation(action: ClaimsNavigationAction)
    case refreshFiles
    case openDocument(url: URL, title: String)
}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case openFile(file: File)
    case openFilesFor(claim: ClaimModel, files: [File])
    case dismissAddFiles
}
