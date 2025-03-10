import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingStack: View {
    let withHeader: Bool
    @StateObject var vm = CrossSellingViewModel()
    @PresentableStore var store: CrossSellStore

    public init(
        withHeader: Bool
    ) {
        self.withHeader = withHeader
    }

    public var body: some View {
        successView
            .onAppear {
                store.send(.fetchCrossSell)
            }
    }

    @ViewBuilder
    private var successView: some View {
        if !vm.crossSells.isEmpty {
            hSection {
                VStack(spacing: 16) {
                    ForEach(vm.crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell)
                            .transition(.slide)
                    }
                }
            }
            .withHeader {
                if withHeader {
                    HStack(alignment: .center, spacing: 8) {
                        CrossSellingUnseenCircle(vm: vm)
                        hText(L10n.InsuranceTab.CrossSells.title)
                            .padding(.leading, 2)
                            .foregroundColor(hTextColor.Opaque.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.bottom, .padding8)
                }
            }
            .sectionContainerStyle(.transparent)
            .transition(.slide)
        }
    }
}

@MainActor
class CrossSellingViewModel: ObservableObject {
    @Published var crossSells: [CrossSell] = [] {
        didSet {
            self.hasUnseenCrossSell = crossSells.contains(where: { crossSell in
                !crossSell.hasBeenSeen
            })
        }
    }
    @Published var hasUnseenCrossSell: Bool = false
    @PresentableStore var store: CrossSellStore
    private var service = CrossSellService()
    var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await getCrossSells()
        }
    }

    @MainActor
    func getCrossSells() async {
        store.send(.fetchCrossSell)

        store.stateSignal
            .compactMap({ $0.crossSells })
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { crossSells in
                self.crossSells = crossSells
            }
            .store(in: &cancellables)
    }
}
