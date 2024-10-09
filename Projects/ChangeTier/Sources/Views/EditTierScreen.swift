import SwiftUI
import hCore
import hCoreUI

struct EditTierScreen: View {
    @State var selectedTier: String?
    private let vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
        self.selectedTier = vm.selectedTier?.name ?? vm.tiers.first?.name
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(vm.tiers, id: \.self) { tier in
                        hRadioField(
                            id: tier.name,
                            leftView: {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        hText(tier.productVariant?.displayNameTier ?? "")
                                        Spacer()
                                        hPill(
                                            text: tier.premium.formattedAmountPerMonth,
                                            color: .grey(translucent: false),
                                            colorLevel: .one
                                        )
                                        .hFieldSize(.small)
                                    }
                                    if let subTitle = tier.productVariant?.tierDescription {
                                        hText(subTitle)
                                            .foregroundColor(hTextColor.Opaque.secondary)
                                            .fixedSize()
                                    }
                                }
                                .asAnyView
                            },
                            selected: $selectedTier,
                            error: nil,
                            useAnimation: true
                        )
                        .hFieldLeftAttachedView
                    }
                }
            }
            .padding(.top, 16)
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        vm.setTier(for: self.selectedTier ?? "")
                        changeTierNavigationVm.isEditTierPresented = false
                    } content: {
                        hText(L10n.generalContinueButton)
                    }

                    hButton.LargeButton(type: .ghost) {
                        changeTierNavigationVm.isEditTierPresented = false
                    } content: {
                        hText(L10n.generalCancelButton)
                    }

                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .configureTitleView(self)
    }
}

extension EditTierScreen: TitleView {
    public func getTitleView() -> UIView {
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.tierFlowSelectCoverageTitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            hText(L10n.tierFlowSelectCoverageSubtitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .padding8)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return EditTierScreen(
        vm: .init(
            changeTierInput: .init(
                source: .betterCoverage,
                contractIds: [
                    .init(
                        contractId: "contractId1",
                        contractDisplayName: "contractDisplayName",
                        contractExposureName: "contractExposureName"
                    )
                ]
            )
        )
    )
}
