import Apollo
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore

public final class ForeverStore: LoadingStateStore<ForeverState, ForeverAction, ForeverLoadingType> {
    @Inject var foreverService: ForeverService

    public override func effects(
        _ getState: @escaping () -> ForeverState,
        _ action: ForeverAction
    ) -> FiniteSignal<ForeverAction>? {
        switch action {
        case .fetch:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let data = try await self.foreverService.getMemberReferralInformation()
                        callback(.value(.setForeverData(data: data)))
                    } catch {
                        self.setError(L10n.General.errorBody, for: .fetchForeverData)
                    }
                }
                return disposeBag
            }
        default:
            break
        }
        return nil
    }

    public override func reduce(_ state: ForeverState, _ action: ForeverAction) -> ForeverState {
        var newState = state

        switch action {
        case .fetch:
            self.setLoading(for: .fetchForeverData)
        case let .setForeverData(data):
            self.removeLoading(for: .fetchForeverData)
            newState.foreverData = data
        default:
            break
        }

        return newState
    }
}
