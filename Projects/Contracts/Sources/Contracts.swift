import EditCoInsuredShared
import Foundation
import Presentation
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

struct Contracts: View {
    @PresentableStore var store: ContractStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let showTerminated: Bool

    public init(
        showTerminated: Bool
    ) {
        self.showTerminated = showTerminated
    }

    func fetch() {
        store.send(.fetchContracts)
    }

    public var body: some View {
        hForm {
            ContractTable(showTerminated: showTerminated)
                .padding(.top, 8)
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hBackgroundColor.primary))
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
        .onPullToRefresh {
            await store.sendAsync(.fetch)
        }
        .hFormAttachToBottom {
            if showTerminated {
                hSection {
                    InfoCard(text: L10n.InsurancesTab.cancelledInsurancesNote, type: .info)
                }
                .sectionContainerStyle(.transparent)
                .padding(.vertical, 16)
            }
        }
    }
}

public indirect enum ContractFilter: Equatable, Hashable {
    var displaysActiveContracts: Bool {
        switch self {
        case .terminated: return false
        case .active: return true
        case .none: return false
        }
    }

    var displaysTerminatedContracts: Bool {
        switch self {
        case .terminated: return true
        case .active: return false
        case .none: return false
        }
    }

    var emptyFilter: ContractFilter {
        switch self {
        case let .terminated(ifEmpty): return ifEmpty
        case let .active(ifEmpty): return ifEmpty
        case .none: return .none
        }
    }

    case terminated(ifEmpty: ContractFilter)
    case active(ifEmpty: ContractFilter)
    case none
}
