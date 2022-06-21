import Presentation
import SwiftUI
import hCore
import hCoreUI

struct TerminatedContractsTable: View {
    @PresentableStore var store: ContractStore

    var body: some View {
        VStack {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.terminatedContracts
                }
            ) {
                terminatedContracts in
                ForEach(terminatedContracts, id: \.id) { contract in
                    ContractRow(id: contract.id)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 15)
                        .transition(.slide)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

extension TerminatedContractsTable {
    public static func journey(
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: TerminatedContractsTable(),
            style: style,
            options: options
        ) { _ in
            ContinueJourney()
        }
    }
}
