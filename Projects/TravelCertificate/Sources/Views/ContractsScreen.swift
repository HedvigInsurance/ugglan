import SwiftUI
import hCore
import hCoreUI

struct ContractsScreen: View {
    @State var isLoading: Bool = false
    let specifications: [TravelInsuranceContractSpecification]
    let router: Router
    let itemPickerConfig: ItemConfig<TravelInsuranceContractSpecification>

    init(
        router: Router,
        specifications: [TravelInsuranceContractSpecification]
    ) {
        self.specifications = specifications
        self.router = router
        itemPickerConfig = .init(
            items: {
                return specifications.map {
                    (object: $0, displayName: .init(title: $0.street))
                }
            }(),
            preSelectedItems: {
                guard let preSelected = specifications.first else {
                    return []
                }
                return [preSelected]
            },
            onSelected: { selected in
                if let selected = selected.first?.0 {
                    router.push(TravelCertificateRouterActions.startDate(specification: selected))
                }
            },
            hButtonText: L10n.generalContinueButton
        )
    }

    public var body: some View {
        ItemPickerScreen<TravelInsuranceContractSpecification>(
            config: itemPickerConfig
        )
        .padding(.bottom, .padding16)
        .hFieldSize(.large)
        .hItemPickerAttributes([.singleSelect, .attachToBottom])
        .hFormTitle(title: .init(.small, .heading2, L10n.TravelCertificate.selectContractTitle, alignment: .leading))
        .hButtonIsLoading(isLoading)
    }
}

struct TravelInsuranceContractsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContractsScreen(router: .init(), specifications: [])
    }
}
