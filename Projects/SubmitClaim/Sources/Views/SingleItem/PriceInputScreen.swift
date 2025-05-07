import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct PriceInputScreen: View {
    @State var purchasePrice: String = ""
    @State var type: ClaimsFlowSingleItemFieldType? = .purchasePrice
    @EnvironmentObject var router: Router
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel

    let currency: String

    init(
        claimsNavigationVm: SubmitClaimNavigationViewModel
    ) {
        self.claimsNavigationVm = claimsNavigationVm
        self.currency = claimsNavigationVm.singleItemModel?.prefferedCurrency ?? ""

        if let purchasePrice = claimsNavigationVm.singleItemModel?.purchasePrice {
            self.purchasePrice = String(purchasePrice)
        }
    }

    var body: some View {
        hForm {
            hSection {
                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: $purchasePrice,
                    equals: $type,
                    focusValue: .purchasePrice,
                    placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
                    suffix: currency
                )
            }
        }
        .hFormContentPosition(.compact)
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hSaveButton {
                        UIApplication.dismissKeyboard()
                        claimsNavigationVm.singleItemModel?.purchasePrice = Double(purchasePrice)
                        claimsNavigationVm.isPriceInputPresented = false
                    }

                    hButton(
                        .large,
                        .ghost,
                        title: L10n.generalNotSure,
                        {
                            UIApplication.dismissKeyboard()
                            router.dismiss()
                        }
                    )
                }
            }
            .padding(.top, .padding16)
        }
        .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
            scrollView.keyboardDismissMode = .interactive
        }
    }
}
