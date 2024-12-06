import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    var addonService = AddonsService()
    @Published var fetchAddonsViewState: ProcessingState = .loading
    @Published var submittingAddonsViewState: ProcessingState = .loading
    @Published var selectedQuote: AddonQuote?
    @Published var addonOffer: AddonOffer?
    @Published var activationDate: Date?
    @Published var contractId: String?

    init(contractId: String) {
        Task {
            await getAddons()

            self._selectedQuote = Published(
                initialValue: addonOffer?.quotes.first
            )
        }
    }

    func getAddons() async {
        withAnimation {
            self.fetchAddonsViewState = .loading
        }

        do {
            let data = try await addonService.getAddon(contractId: contractId ?? "")

            withAnimation {
                self.addonOffer = data
                self.fetchAddonsViewState = .success
            }
        } catch let exception {
            self.fetchAddonsViewState = .error(errorMessage: exception.localizedDescription)
        }
    }

    func submitAddons() async {
        withAnimation {
            self.submittingAddonsViewState = .loading
        }
        do {
            let data = try await addonService.submitAddon(
                quoteId: selectedQuote?.quoteId ?? "",
                addonId: selectedQuote?.addonId ?? ""
            )
            withAnimation {
                self.activationDate = data
                self.submittingAddonsViewState = .success
            }
        } catch let exception {
            self.submittingAddonsViewState = .error(errorMessage: exception.localizedDescription)
        }
    }
}
