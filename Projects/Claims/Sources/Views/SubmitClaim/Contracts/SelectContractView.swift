import SwiftUI
import hCore
import hCoreUI

struct SelectContractView: View {
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    @StateObject var vm = SelectContractViewModel()

    var body: some View {
        let contractStep = claimsNavigationVm.contractSelectModel
        ItemPickerScreen<FlowClaimContractSelectOptionModel>(
            config: .init(
                items: {
                    return contractStep?.availableContractOptions
                        .compactMap({ (object: $0, displayName: .init(title: $0.displayName, subTitle: $0.subTitle)) })
                        ?? []
                }(),
                preSelectedItems: {
                    if let preselected = contractStep?.availableContractOptions
                        .first(where: { $0.id == contractStep?.selectedContractId })
                    {
                        return [preselected]
                    }
                    return []
                },
                onSelected: { selectedContract in
                    if let object = selectedContract.first?.0 {
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
                singleSelect: true,
                attachToBottom: true
            )
        )
        .padding(.bottom, .padding16)
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.claimTriagingAboutTitile,
                alignment: .leading
            )
        )
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
        return SelectContractView()
            .environmentObject(ClaimsNavigationViewModel())
    }
}
