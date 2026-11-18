import ChangeMileageCore
import SwiftUI
import hCore
import hCoreUI

struct MileagePickerScreen: View {
    private let vm: ChangeMileageViewModel
    @State private var selectedQuoteId: String?
    @Environment(ChangeMileageNavigationViewModel.self) var navigationVm

    init(vm: ChangeMileageViewModel) {
        self.vm = vm
        _selectedQuoteId = State(initialValue: vm.selectedQuote?.id)
    }

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 0) {
                    // TODO: Add "Choose mileage" / "Välj körsträcka" to Lokalise
                    hText("Välj körsträcka", style: .heading1)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .accessibilityAddTraits(.isHeader)
                    // TODO: Add "How far the car is driven per year, by everyone who drives it" / "Hur långt bilen körs per år, av alla som kör den" to Lokalise
                    hText("Hur långt bilen körs per år, av alla som kör den", style: .heading1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(vm.quotes) { quote in
                        hRadioField(
                            id: quote.id,
                            leftView: { leftView(for: quote) },
                            selected: $selectedQuoteId,
                            error: nil,
                            useAnimation: true
                        )
                        .hFieldLeftAttachedView
                    }
                }
            }
            .padding(.top, .padding16)
            .sectionContainerStyle(.transparent)
            .hFieldSize(.medium)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton(.large, .primary, content: .init(title: L10n.generalConfirm)) {
                        vm.select(quoteId: selectedQuoteId ?? "")
                        navigationVm.isPickerPresented = nil
                    }
                    .accessibilityHint(L10n.voiceoverOptionSelected + selectedDisplayName)
                    hCancelButton {
                        navigationVm.isPickerPresented = nil
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
    }

    private var selectedDisplayName: String {
        vm.quotes.first(where: { $0.id == selectedQuoteId })?.displayName ?? ""
    }

    private func leftView(for quote: MileageQuote) -> AnyView {
        VStack(alignment: .leading, spacing: .padding8) {
            HStack {
                hText(quote.displayName)
                Spacer()
                hPill(text: quote.totalCost.net.formattedAmountPerMonth, color: .grey, colorLevel: .two)
                    .hFieldSize(.small)
            }
            if quote.isCurrent {
                // TODO: Add "Current" / "Nuvarande" to Lokalise
                hText("Nuvarande", style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .asAnyView
    }
}
