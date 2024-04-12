import EditCoInsuredShared
import Foundation
import Presentation
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

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

public class ContractsNavigationViewModel: ObservableObject {
    public init() {}

    @Published public var insurableLimit: InsurableLimits?
    @Published public var document: InsuranceTerm?
    @Published public var renewalDocument: Document?

    @Published public var terminationContract: Contract?
    @Published public var editCoInsuredConfig: InsuredPeopleConfig?
    @Published public var changeYourInformationContract: Contract?
    @Published public var insuranceUpdate: Contract?
    @Published public var isChangeAddressPresented = false
    @Published public var isChatPresented = false

    @Published public var externalNavigationRedirect = NavigationPath()
}

public struct Contracts: View {
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

extension TerminationConfirmConfig {
    public init(
        contract: Contract
    ) {
        self.init(
            contractId: contract.id,
            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
            contractExposureName: contract.exposureDisplayName,
            activeFrom: contract.currentAgreement?.activeFrom
        )
    }
}
