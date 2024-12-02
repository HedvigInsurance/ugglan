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
    @Published var informationText: String?

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
            let data = try await addonService.getAddon()

            withAnimation {
                self.addonOptions = data.options
                self.informationText = data.informationText
                self.fetchAddonsViewState = .success
            }
        } catch let exception {
            self.fetchAddonsViewState = .error(errorMessage: exception.localizedDescription)
        }
    }

    func submitAddons() {
        withAnimation {
            self.submittingAddonsViewState = .loading
        }

        /* TODO: REMOVE DELAY WHEN IMPLEMENTATION IS IN PLACE */
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            do {
                /** TODO: IMPLEMENT  **/
                withAnimation {
                    self.submittingAddonsViewState = .success
                }
            } catch let exception {
                self.submittingAddonsViewState = .error(errorMessage: exception.localizedDescription)
            }
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
