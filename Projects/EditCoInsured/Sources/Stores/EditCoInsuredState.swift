import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct EditCoInsuredState: StateProtocol {
    var loadingStates: [EditCoInsuredAction: LoadingState<String>] = [:]
    public init() {}
}
