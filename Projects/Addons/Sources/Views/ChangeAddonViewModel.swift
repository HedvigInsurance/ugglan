import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    @Inject private var addonService: AddonsClient
    @Published var viewState: ProcessingState = .loading
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
            self.viewState = .loading
        }

        do {
            let data = try await addonService.getAddon()

            withAnimation {
                self.addonOptions = data.options
                self.informationText = data.informationText
                self.viewState = .success
            }
        } catch let exception {
            self.viewState = .error(errorMessage: exception.localizedDescription)
        }
    }

    func getContractInformation(contractId: String) async {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let data = try await addonService.getContract(contractId: contractId)

            withAnimation {
                self.contractInformation = data
                self.viewState = .success
            }
        } catch let exception {
            self.viewState = .error(errorMessage: exception.localizedDescription)
        }
    }
}
