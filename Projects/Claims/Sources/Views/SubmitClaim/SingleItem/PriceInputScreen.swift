import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct PriceInputScreen: View {
    @State var purchasePrice: String = ""
    @State var type: ClaimsFlowSingleItemFieldType? = .purchasePrice
    @EnvironmentObject var router: Router
    @ObservedObject var claimsNavigationVm: ClaimsNavigationViewModel

    let currency: String

    init(
        claimsNavigationVm: ClaimsNavigationViewModel
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
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        UIApplication.dismissKeyboard()
                        claimsNavigationVm.singleItemModel?.purchasePrice = Double(purchasePrice)
                        claimsNavigationVm.isPriceInputPresented = false
                    } content: {
                        hText(L10n.generalSaveButton, style: .body1)
                    }
                    hButton.LargeButton(type: .ghost) {
                        UIApplication.dismissKeyboard()
                        router.dismiss()
                    } content: {
                        hText(L10n.generalNotSure, style: .body1)
                    }
                }
            }
            .padding(.top, .padding16)
        }
        .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
            scrollView.keyboardDismissMode = .interactive
        }
    }
}
