import Kingfisher
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        LoadingViewWithContent(.postSummary) {
            hForm {
                hSection {
                    VStack(spacing: 8) {
                        matter
                        damageType
                        damageDate
                        place
                        model
                        dateOfPurchase
                        purchasePrice
                    }
                }
                .withHeader {
                    HStack {
                        L10n.changeAddressDetails.hTextNew(.body).foregroundColor(hLabelColorNew.primary)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .hFormAttachToBottom {
                VStack(spacing: 8) {
                    NoticeComponent(text: L10n.claimsComplementClaim)
                    Group {
                        hButton.LargeButtonFilled {
                            store.send(.summaryRequest)
                        } content: {
                            hText(L10n.embarkSubmitClaim)
                        }
                        hButton.LargeButtonText {
                            store.send(.navigationAction(action: .dismissScreen))
                        } content: {
                            hText(L10n.embarkGoBackButton)
                        }
                    }
                    .padding([.leading, .trailing], 16)
                }
            }
        }
        .hUseNewStyle
    }

    @ViewBuilder
    private var matter: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.summaryStep
            }
        ) { summaryStep in
            createRow(with: L10n.claimsCase, and: summaryStep?.title ?? "")
        }
    }

    @ViewBuilder
    private var damageType: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            createRow(with: L10n.claimsDamages, and: singleItemStep?.getAllChoosenDamagesAsText())
        }
    }

    @ViewBuilder
    private var damageDate: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.dateOfOccurenceStep
            }
        ) { dateOfOccurenceStep in
            createRow(with: L10n.Claims.Item.Screen.Date.Of.Incident.button, and: dateOfOccurenceStep?.dateOfOccurence)
        }
    }

    @ViewBuilder
    private var place: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.locationStep
            }
        ) { locationStep in
            createRow(with: L10n.Claims.Location.Screen.title, and: locationStep?.getSelectedOption()?.displayName)
        }
    }

    @ViewBuilder
    private var model: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            createRow(with: L10n.Claims.Item.Screen.Model.button, and: singleItemStep?.getBrandOrModelName())
        }
    }

    @ViewBuilder
    private var dateOfPurchase: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            createRow(with: L10n.Claims.Item.Screen.Date.Of.Purchase.button, and: singleItemStep?.purchaseDate)
        }
    }

    @ViewBuilder
    private var purchasePrice: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            createRow(
                with: L10n.Claims.Item.Screen.Purchase.Price.button,
                and: singleItemStep?.returnDisplayStringForSummaryPrice
            )
        }
    }

    @ViewBuilder
    func createRow(with title: String?, and value: String?) -> some View {
        if let title, let value {
            HStack {
                title.hTextNew(.body).foregroundColor(hLabelColorNew.secondary)
                Spacer()
                value.hTextNew(.body).foregroundColor(hLabelColorNew.secondary)
            }
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
