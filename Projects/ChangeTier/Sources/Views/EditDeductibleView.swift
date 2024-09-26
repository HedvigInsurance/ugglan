import SwiftUI
import hCore
import hCoreUI

struct EditDeductibleView: View {
    @State var selectedDeductible: String?
    var vm: ChangeTierViewModel
    let getDeductibles: [Deductible]
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm

        if !(vm.selectedTier?.deductibles.isEmpty ?? true) {
            self.getDeductibles = vm.selectedTier?.deductibles ?? []
        } else {
            self.getDeductibles = vm.tiers.first(where: { $0.name == vm.selectedTier?.name })?.deductibles ?? []
        }

        self.selectedDeductible = vm.selectedDeductible?.id ?? vm.selectedTier?.deductibles.first?.id
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(getDeductibles, id: \.self) { deductible in
                        hRadioField(
                            id: deductible.id,
                            leftView: {
                                VStack(alignment: .leading, spacing: .padding8) {
                                    HStack {
                                        let displayTitle =
                                            (deductible.deductibleAmount?.formattedAmount ?? "") + " + "
                                            + String(deductible.deductiblePercentage ?? 0) + "%"
                                        hText(displayTitle)
                                        Spacer()
                                        hText(deductible.premium?.formattedAmountPerMonth ?? "")
                                    }
                                    hText(deductible.subTitle ?? "")
                                        .foregroundColor(hTextColor.Opaque.secondary)
                                }
                                .asAnyView
                            },
                            selected: $selectedDeductible,
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
                        vm.setDeductible(for: self.selectedDeductible ?? "")
                        changeTierNavigationVm.isEditDeductiblePresented = false
                    } content: {
                        hText(L10n.generalConfirm)
                    }

                    hButton.LargeButton(type: .ghost) {
                        changeTierNavigationVm.isEditDeductiblePresented = false
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

extension EditDeductibleView: TitleView {
    public func getTitleView() -> UIView {
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.tierFlowSelectDeductibleTitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            hText("Amount deducted from the compensation", style: .heading1)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .padding8)
    }
}

#Preview{
    EditDeductibleView(vm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
