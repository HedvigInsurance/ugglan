import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: CompareTierViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        succesView.loading($vm.viewState)
            .hErrorViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            vm.getProductVariantComparision()
                        }
                    ),
                    dismissButton:
                        .init(
                            buttonTitle: L10n.generalCloseButton,
                            buttonAction: {
                                changeTierNavigationVm.router.dismiss()
                            }
                        )
                )
            )
    }

    @ViewBuilder
    var succesView: some View {
        hForm {
            ScrollableSegmentedView(
                vm: vm.scrollableSegmentedViewModel,
                contentFor: { id in
                    mainContent(for: id)
                }
            )
        }
    }

    func mainContent(for tierId: String) -> some View {
        VStack(spacing: 4) {
            ForEach(vm.perils[tierId] ?? [], id: \.id) { peril in
                hSection {
                    SwiftUI.Button {
                        withAnimation {
                            vm.extended.toggle()
                        }
                    } label: {
                        EmptyView()
                    }
                    .buttonStyle(
                        CompareTierButtonStyle(
                            peril: peril,
                            extended: $vm.extended
                        )
                    )
                    .modifier(
                        BackgorundColorAnimation(
                            animationTrigger: .constant(false),
                            color: hSurfaceColor.Opaque.primary,
                            animationColor: hSurfaceColor.Opaque.secondary
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                }
            }
            .hFieldSize(.small)
        }
    }
}

struct CompareTierButtonStyle: ButtonStyle {
    var peril: Perils

    @Binding var extended: Bool

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 11) {
            HStack(spacing: 8) {
                if let color = peril.color {
                    Group {
                        if peril.isDisabled {
                            Circle()
                                .fill(hFillColor.Opaque.disabled)
                        } else {
                            Circle()
                                .fill(Color(hexString: color))
                        }
                    }
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, .padding4)
                }
                hText(peril.title, style: .heading1)
                    .lineLimit(1)
                    .foregroundColor(getTextColor)
                Spacer()

                if let covered = peril.covered.first, covered != "" {
                    hPill(text: covered, color: .blue, colorLevel: .two)
                } else if !(peril.isDisabled) {
                    Image(
                        uiImage: hCoreUIAssets.checkmark.image
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(getTextColor)
                } else {
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(getTextColor)
                }
            }

            if extended {
                hText(peril.description, style: .label)
                    .padding(.bottom, .padding12)
                    .foregroundColor(getTextColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, .padding32)
            }
        }
        .padding(.horizontal, .padding16)
        .padding(.top, 15)
        .padding(.bottom, 17)
        .contentShape(Rectangle())

    }

    @hColorBuilder
    var getTextColor: some hColor {
        if peril.isDisabled {
            hTextColor.Opaque.disabled
        } else {
            hTextColor.Opaque.primary
        }
    }
}

public class CompareTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ProcessingState = .loading
    @Published var selectedTier: Tier?
    @Published var tiers: [Tier]
    @Published var extended = false

    @Published var perils: [String: [Perils]] = [:]
    var scrollableSegmentedViewModel: ScrollableSegmentedViewModel = .init(pageModels: [])

    init(
        tiers: [Tier],
        selectedTier: Tier? = nil
    ) {
        self.selectedTier = selectedTier
        self.tiers = tiers
        self.getProductVariantComparision()
    }

    private func getPerils(
        tierNames: [String]?,
        rows: [ProductVariantComparison.ProductVariantComparisonRow]?
    ) -> [String: [Perils]] {
        var tempPerils: [String: [Perils]] = [:]
        var index = 0

        tierNames?
            .forEach({ tierName in
                let cells = rows?
                    .map({ row in
                        let cellForIndex = row.cells[index]
                        return Perils(
                            id: row.title,
                            title: row.title,
                            description: row.description,
                            color: row.colorCode,
                            covered: [cellForIndex.coverageText ?? ""],
                            isDisabled: !cellForIndex.isCovered
                        )
                    })

                tempPerils[tierName] = cells
                index = index + 1
            })
        return tempPerils
    }

    public func getProductVariantComparision() {
        withAnimation {
            viewState = .loading
        }
        Task { @MainActor in
            do {
                var termsVersionsToCompare: [String] = []
                tiers.forEach({ tier in
                    tier.quotes.forEach({ quote in
                        if let termsVersion = quote.productVariant?.termsVersion,
                            !termsVersionsToCompare.contains(termsVersion)
                        {
                            termsVersionsToCompare.append(termsVersion)
                        }
                    })
                })

                let mockTermsVersionsToCompare =
                    [
                        "SE_DOG_BASIC-20230330-HEDVIG-null",
                        "SE_DOG_STANDARD-20230330-HEDVIG-null",
                        "SE_DOG_PREMIUM-20230410-HEDVIG-null",
                    ]

                let productVariantComparisionData = try await service.compareProductVariants(
                    //                    termsVersion: termsVersionsToCompare
                    termsVersion: mockTermsVersionsToCompare
                )

                let columns = productVariantComparisionData.variantColumns
                let rows = productVariantComparisionData.rows
                let tierNames = columns.compactMap({ $0.displayNameTier })

                self.perils = getPerils(tierNames: tierNames, rows: rows)

                let pageModels: [PageModel] = tierNames.compactMap({ PageModel(id: $0, title: $0) })
                let currentId = productVariantComparisionData.variantColumns
                    .first(where: { $0.displayNameTier == selectedTier?.name })?
                    .displayNameTier

                self.scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
                    pageModels: pageModels,
                    currentId: currentId
                )

                withAnimation {
                    viewState = .success
                }
            } catch let error {
                withAnimation {
                    self.viewState = .error(
                        errorMessage: error.localizedDescription
                    )
                }
            }
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })

    let vm: CompareTierViewModel = .init(
        tiers: [
            .init(
                id: "tier1",
                name: "Bas",
                level: 0,
                quotes: [
                    .init(
                        id: "quote1",
                        quoteAmount: .init(amount: "220", currency: "SEK"),
                        quotePercentage: 0,
                        subTitle: nil,
                        premium: .init(amount: "220", currency: "SEK"),
                        displayItems: [],
                        productVariant: nil
                    )
                ],
                exposureName: "exposure name"
            )
        ],
        selectedTier: nil
    )

    vm.perils["Bas"] = [
        Perils(
            id: "peril1",
            title: "peril1",
            description: "description",
            color: nil,
            covered: ["30 000 kr"],
            isDisabled: false
        )
    ]

    return CompareTierScreen(vm: vm)
}
