import SwiftUI
import hCore
import hCoreUI

public struct BrandPickerScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        hForm {

            hSection {

                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.newClaims
                    }
                ) { claim in

                    let brands = claim.listOfBrands

                    ForEach(brands ?? [], id: \.self) { brand in
                        hRow {
                            hText(brand.displayName, style: .body)
                                .foregroundColor(hLabelColor.primary)
                        }
                        .onTap {
                            store.send(.submitBrand(brand: brand))
                        }
                    }
                }
            }
        }
    }
}

public struct ModelPickerScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {

        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.newClaims
            }
        ) { claim in

            let filteredModels = claim.filteredListOfModels

            if filteredModels?.count ?? 0 > 0 {

                ForEach(filteredModels ?? [], id: \.self) { model in

                    hRow {
                        hText(model.displayName, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .onTap {
                        store.send(.submitModel(model: model))
                    }
                }
            } else {
                let _ = store.send(.dissmissNewClaimFlow)
            }
        }
    }
}
