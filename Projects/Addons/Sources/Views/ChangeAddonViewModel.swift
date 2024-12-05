import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    var addonService = AddonsService()
    @Published var fetchAddonsViewState: ProcessingState = .loading
    @Published var submittingAddonsViewState: ProcessingState = .loading
    @Published var selectedSubOption: AddonSubOptionModel?
    @Published var addonOptions: [AddonOptionModel]?
    @Published var contractInformation: AddonContract?
    @Published var activationDate: Date?
    @Published var addonId: String?
    @Published var quoteId: String?

    init(contractId: String) {
        Task {
            await getAddons()
            await getContractInformation(contractId: contractId)

            self._selectedSubOption = Published(
                initialValue: addonOptions?.first?.subOptions.first
            )
        }
    }

    func getAddons() async {
        withAnimation {
            self.fetchAddonsViewState = .loading
        }

        do {
            let data = try await addonService.getAddon(contractId: contractInformation?.contractId ?? "")

            withAnimation {
                self.addonOptions = data.options
                self.activationDate = data.activationDate
                self.addonId = data.id
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
            try await addonService.submitAddon(quoteId: quoteId ?? "", addonId: addonId ?? "")
            withAnimation {
                self.submittingAddonsViewState = .success
            }
        } catch let exception {
            self.submittingAddonsViewState = .error(errorMessage: exception.localizedDescription)
        }
    }

    func getContractInformation(contractId: String) async {
        withAnimation {
            self.fetchAddonsViewState = .loading
        }

        do {
            let data = try await addonService.getContract(contractId: contractId)

            withAnimation {
                self.contractInformation = data
                self.fetchAddonsViewState = .success
            }
        } catch let exception {
            self.fetchAddonsViewState = .error(errorMessage: exception.localizedDescription)
        }
    }
}
