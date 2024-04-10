import SwiftUI
import hCore
import hCoreUI

struct ContractsScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    @State var isLoading: Bool = false
    let specifications: [TravelInsuranceContractSpecification]

    init(specifications: [TravelInsuranceContractSpecification]) {
        self.specifications = specifications
    }

    public var body: some View {
        CheckboxPickerScreen<TravelInsuranceContractSpecification>(
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
                    store.send(.navigation(.openStartDateScreen(spacification: selected)))
                }
            },
            singleSelect: true,
            attachToBottom: true,
            hButtonText: L10n.generalContinueButton
        )
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
