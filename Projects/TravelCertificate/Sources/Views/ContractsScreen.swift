import SwiftUI
import hCore
import hCoreUI

struct ContractsScreen: View {
    @State var isLoading: Bool = false
    let specifications: [TravelInsuranceContractSpecification]
    @EnvironmentObject var router: Router

    init(specifications: [TravelInsuranceContractSpecification]) {
        self.specifications = specifications
    }

    public var body: some View {
        ItemPickerScreen<TravelInsuranceContractSpecification>(
            config: .init(
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
                singleSelect: true,
                attachToBottom: true,
                hButtonText: L10n.generalContinueButton
            )
        )
        .padding(.bottom, .padding16)
        .hFormTitle(title: .init(.standard, .title1, L10n.TravelCertificate.selectContractTitle))
        .hButtonIsLoading(isLoading)
        .hDisableScroll
    }
}

struct TravelInsuranceContractsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContractsScreen(specifications: [])
    }
}
