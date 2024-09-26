import SwiftUI
import hCore
import hCoreUI

struct EditTier: View {
    @State var selectedTier: String?
    var vm: ChangeTierViewModel
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
                                VStack(alignment: .leading, spacing: .padding8) {
                                    HStack {
                                        hText(tier.name)
                                        Spacer()
                                        hText(tier.premium.formattedAmountPerMonth)
                                    }
                                    hText(String(tier.productVariant.displayNameTierLong ?? ""))
                                        .foregroundColor(hTextColor.Opaque.secondary)
                                        .fixedSize()
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

extension EditTier: TitleView {
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
            hText("Find the right coverage for your needs", style: .heading1)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .padding8)
    }
}

#Preview{
    EditTier(vm: .init())
}
