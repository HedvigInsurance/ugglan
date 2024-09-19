import SwiftUI
import hCore
import hCoreUI

struct EditDeductible: View {
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
                    ForEach(vm.deductibles, id: \.self) { deductible in
                        hRadioField(
                            id: deductible.title,
                            leftView: {
                                VStack(alignment: .leading, spacing: .padding8) {
                                    HStack {
                                        hText(deductible.title)
                                        Spacer()
                                        hText(deductible.label)
                                    }
                                    hText(deductible.subTitle)
                                        .fixedSize()
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
            self.selectedDeductible = vm.selectedDeductible?.title ?? vm.deductibles.first?.title
        }
    }
}

#Preview{
    EditDeductible(vm: .init())
}
