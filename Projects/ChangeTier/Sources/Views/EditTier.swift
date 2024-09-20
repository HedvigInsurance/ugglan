import SwiftUI
import hCore
import hCoreUI

struct EditTier: View {
    @State var selectedTier: String?
    var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: SelectTierNavigationViewModel

    init(
        vm: SelectTierViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(vm.tiers, id: \.self) { tier in
                        hRadioField(
                            id: tier.title ?? "",
                            leftView: {
                                VStack(alignment: .leading, spacing: .padding8) {
                                    HStack {
                                        hText(tier.title ?? "")
                                        Spacer()
                                        hText(tier.premium ?? "" + " kr/mo")
                                    }
                                    hText(tier.subTitle ?? "")
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
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        vm.setTier(for: self.selectedTier ?? "")
                        selectTierNavigationVm.isEditTierPresented = false
                    } content: {
                        hText(L10n.generalContinueButton)
                    }

                    hButton.LargeButton(type: .ghost) {
                        selectTierNavigationVm.isEditTierPresented = false
                    } content: {
                        hText(L10n.generalCancelButton)
                    }

                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
        .onAppear {
            self.selectedTier = vm.selectedTier?.title ?? vm.tiers.first?.title
        }
    }
}

#Preview{
    EditTier(vm: .init())
}
