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
    let selectedBrand: Brand

    public init(
        selectedBrand: Brand
    ) {
        self.selectedBrand = selectedBrand
    }

    public var body: some View {

        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.newClaims
            }
        ) { claim in

            let models = claim.listOfModels
            var array: [Model] = []

            //            for brand in models {
            //                array.append(brand)
            //            }

            ForEach(models ?? [], id: \.self) { model in

                if model.itemBrandId == selectedBrand.itemBrandId {

                    hRow {
                        hText(model.displayName, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .onTap {
                        store.send(.submitBrandAndModel(brand: selectedBrand, model: model))
                    }
                }
            }
        }
    }
}
