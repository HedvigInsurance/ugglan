import hCore
import hCoreUI
import SwiftUI

struct SelectContractView: View {
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @ObservedObject var vm = SelectContractViewModel()
    let itemPickerConfig: ItemConfig<FlowClaimContractSelectOptionModel>

    init(
        claimsNavigationVm: SubmitClaimNavigationViewModel,
        vm: SelectContractViewModel = SelectContractViewModel()
    ) {
        self.claimsNavigationVm = claimsNavigationVm
        self.vm = vm
        itemPickerConfig = .init(
            items: claimsNavigationVm.contractSelectModel?.availableContractOptions
                .compactMap {
                    (object: $0, displayName: .init(title: $0.displayTitle, subTitle: $0.displaySubTitle))
                }
                ?? [],
            preSelectedItems: {
                if let preselected = claimsNavigationVm.contractSelectModel?.availableContractOptions
                    .first(where: { $0.id == claimsNavigationVm.contractSelectModel?.selectedContractId })
                {
                    return [preselected]
                }
                return []
            },
            onSelected: { selectedContract in
                if let object = selectedContract.first?.0 {
                    claimsNavigationVm.contractSelectModel?.selectedContractId = object.id
                    if let model = claimsNavigationVm.contractSelectModel {
                        Task {
                            let step = await vm.contractSelectRequest(
                                contractId: object.id,
                                context: claimsNavigationVm.currentClaimContext ?? "",
                                model: model
                            )
                            if let step {
                                claimsNavigationVm.navigate(data: step)
                            }
                        }
                    }
                }
            },
            buttonText: L10n.generalContinueButton
        )
    }

    var body: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.claimTriagingAboutTitile,
            subtitle: nil
        )
        .hItemPickerAttributes([.singleSelect, .attachToBottom])
        .hButtonIsLoading(vm.state == .loading)
        .claimErrorTrackerForState($vm.state)
    }
}

@MainActor
public class SelectContractViewModel: ObservableObject {
    private let service = SubmitClaimService()
    @Published var state: ProcessingState = .success

    @MainActor
    func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel
    ) async -> SubmitClaimStepResponse? {
        withAnimation {
            state = .loading
        }
        do {
            let data = try await service.contractSelectRequest(contractId: contractId, context: context, model: model)
            withAnimation {
                state = .success
            }
            return data
        } catch let exception {
            withAnimation {
                state = .error(errorMessage: exception.localizedDescription)
            }
        }
        return nil
    }
}

struct SelectContractScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })
        return SelectContractView(claimsNavigationVm: .init())
    }
}
