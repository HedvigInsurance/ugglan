import hCore
import hCoreUI
import SwiftUI

struct TravelCertificateSelectInsuranceScreen: View {
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
            items: specifications.map {
                (
                    object: $0,
                    displayName: .init(title: $0.displayName, subTitle: $0.exposureDisplayName)
                )
            },
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
            buttonText: L10n.generalContinueButton
        )
    }

    var body: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.TravelCertificate.selectContractTitle,
            subtitle: nil
        )
        .hButtonIsLoading(isLoading)
    }
}

struct TravelInsuranceContractsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelCertificateSelectInsuranceScreen(router: .init(), specifications: [])
    }
}
