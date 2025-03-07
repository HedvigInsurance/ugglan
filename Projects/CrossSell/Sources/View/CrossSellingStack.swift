import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingStack: View {
    let withHeader: Bool
    @StateObject var vm = CrossSellingViewModel()

    public init(
        withHeader: Bool
    ) {
        self.withHeader = withHeader
    }

    public var body: some View {
        successView.loading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            Task {
                                await vm.getCrossSells()
                            }
                        }
                    )
                )
            )
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
    @Published var crossSells: [CrossSell] = []
    @Published var hasUnseenCrossSell: Bool = false
    @Published var viewState: ProcessingState = .loading
    private var service = CrossSellService()
    init() {
        Task {
            await getCrossSells()
            hasUnseenCrossSell = crossSells.contains(where: { crossSell in
                !crossSell.hasBeenSeen
            })
        }
    }

    @MainActor
    func getCrossSells() async {
        withAnimation {
            self.viewState = .loading
        }
        do {
            let crossSellData = try await service.getCrossSell()
            self.crossSells = crossSellData

            withAnimation {
                self.viewState = .success
            }
        } catch {
            self.viewState = .error(errorMessage: error.localizedDescription)
        }
    }
}
