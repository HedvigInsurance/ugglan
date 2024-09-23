import SwiftUI
import hCore
import hCoreUI

struct EditDeductibleView: View {
    @State var selectedDeductible: String?
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
                    let deductibles: [Deductible] = vm.selectedTier?.deductibles ?? []

                    ForEach(deductibles, id: \.self) { deductible in
                        hRadioField(
                            id: deductible.id,
                            leftView: {
                                VStack(alignment: .leading, spacing: .padding8) {
                                    HStack {
                                        hText(deductible.deductibleAmount?.formattedAmount ?? "")
                                        Spacer()
                                        hText(String(deductible.deductiblePercentage ?? 0))
                                    }
                                    /* TODO: NOT SURE TO INCLUDE THIS DESIGN WISE */
                                    //                                    hText(deductible.subTitle)
                                    //                                        .fixedSize()
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
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        vm.setDeductible(for: self.selectedDeductible ?? "")
                        selectTierNavigationVm.isEditDeductiblePresented = false
                    } content: {
                        hText(L10n.generalContinueButton)
                    }

                    hButton.LargeButton(type: .ghost) {
                        selectTierNavigationVm.isEditDeductiblePresented = false
                    } content: {
                        hText(L10n.generalCancelButton)
                    }

                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
        .onAppear {
            self.selectedDeductible = vm.selectedDeductible?.id ?? vm.selectedTier?.deductibles.first?.id
        }
    }
}

#Preview{
    EditDeductibleView(vm: .init())
}
