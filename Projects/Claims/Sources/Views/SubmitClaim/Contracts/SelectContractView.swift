import SwiftUI
import hCore
import hCoreUI

struct SelectContractView: View {
    @State var isLoading: Bool = false
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    @StateObject var vm = SelectContractViewModel()

    var body: some View {
        let contractStep = claimsNavigationVm.contractSelectModel
        ItemPickerScreen<FlowClaimContractSelectOptionModel>(
            config: .init(
                items: {
                    return contractStep?.availableContractOptions
                        .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
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
                        Task {
                            let step = await vm.contractSelectRequest(
                                contractId: object.id,
                                context: claimsNavigationVm.currentClaimContext ?? "",
                                model: claimsNavigationVm.contractSelectModel
                            )

                            if let step {
                                claimsNavigationVm.navigate(data: step)
                            }
                        }
                    }
                },
                singleSelect: true,
                attachToBottom: true
            )
        )
        .padding(.bottom, .padding16)
        .hFormTitle(title: .init(.small, .displayXSLong, L10n.claimTriagingAboutTitile))
        .hButtonIsLoading(isLoading)
        .hDisableScroll
    }
}

public class SelectContractViewModel: ObservableObject {
    @Inject private var service: SubmitClaimClient

    @MainActor
    func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel?
    ) async -> SubmitClaimStepResponse? {
        do {
            let data = try await service.contractSelectRequest(contractId: contractId, context: context, model: model)

            return data
        } catch let exception {}
        return nil
    }
}

struct SelectContractScreen_Previews: PreviewProvider {
    static var previews: some View {
        SelectContractView()
    }
}
