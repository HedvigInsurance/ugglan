import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct ClaimHistory: View {
    @ObservedObject var vm = ClaimHistoryViewModel()
    var onTap: (ClaimModel) -> Void

    public init(
        onTap: @escaping (ClaimModel) -> Void
    ) {
        self.onTap = onTap
    }

    public var body: some View {
        if vm.historyClaims.isEmpty {
            StateView(
                type: .empty,
                title: L10n.ClaimHistory.EmptyState.title,
                bodyText: L10n.ClaimHistory.EmptyState.body,
                formPosition: .center
            )
        } else {
            claimHistoryView
        }
    }

    var claimHistoryView: some View {
        hForm {
            ForEach(vm.historyClaims, id: \.id) { claim in
                hSection {
                    hRow {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                hText(claim.claimType)
                                Spacer()
                                if let outcome = claim.outcome?.text {
                                    hPill(text: outcome, color: .clear)
                                }
                            }
                            if let submittedAt = getSubTitle(for: claim) {
                                hText(submittedAt, style: .label)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                    }
                    .withChevronAccessory
                    .onTap {
                        onTap(claim)
                    }
                }
                .sectionContainerStyle(.transparent)
                .hWithoutHorizontalPadding([.row])
            }
        }
        .onAppear {
            vm.fetch()
        }
    }

    func getSubTitle(for claim: ClaimModel) -> String? {
        guard let submittedAt = claim.submittedAt else { return nil }
        return L10n.ClaimStatus.ClaimDetails.submitted + " "
            + (submittedAt.localDateToIso8601Date?.displayDateMMMMDDYYYYFormat ?? "")
    }
}

@MainActor
class ClaimHistoryViewModel: ObservableObject {
    @PresentableStore private var store: ClaimsStore
    private var stateObserver: AnyCancellable?
    @Published var historyClaims: [ClaimModel] = []

    init() {
        stateObserver = store.stateSignal
            .receive(on: RunLoop.main)
            .map(\.historyClaims)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.historyClaims = state ?? []
            }
        historyClaims = store.state.historyClaims ?? []
    }

    func fetch() {
        store.send(.fetchHistoryClaims)
    }
}

#Preview {
    ClaimHistory(onTap: { _ in })
}
