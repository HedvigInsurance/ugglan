import Apollo
import Foundation
import PresentableStore
import SwiftUI
import hCore

public final class ForeverStore: LoadingStateStore<ForeverState, ForeverAction, ForeverLoadingType> {
    @Inject var foreverService: ForeverClient

    public override func effects(
        _ getState: @escaping () -> ForeverState,
        _ action: ForeverAction
    ) async {
        switch action {
        case .fetch:
            do {
                let data = try await self.foreverService.getMemberReferralInformation()
                send(.setForeverData(data: data))
            } catch {
                self.setError(L10n.General.errorBody, for: .fetchForeverData)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: ForeverState, _ action: ForeverAction) -> ForeverState {
        var newState = state

        switch action {
        case .fetch:
            if newState.foreverData == nil {
                self.setLoading(for: .fetchForeverData)
            }
        case let .setForeverData(data):
            self.removeLoading(for: .fetchForeverData)
            newState.foreverData = data
        }
        return newState
    }
}
