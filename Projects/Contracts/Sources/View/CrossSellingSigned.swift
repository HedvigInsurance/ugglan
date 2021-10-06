import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingSigned: View {
    @PresentableStore var store: ContractStore
    var startDate: Date

    public init(
        startDate: Date? = nil
    ) {
        self.startDate = startDate ?? Date()
    }

    var displayDate: String {
        guard let localDateString = startDate.localDateString else {
            return ""
        }

        let crossSellTitle = store.state.focusedCrossSell?.title.lowercased() ?? ""

        if Calendar.current.isDateInToday(startDate) {
            return L10n.PurchaseConfirmationNew.InsuranceToday.AppState.description(crossSellTitle)
        } else {
            return L10n.PurchaseConfirmationNew.InsuranceActiveInFuture.AppState.description(
                crossSellTitle,
                localDateString
            )
        }
    }

    var displayTitle: String {
        return L10n.PurchaseConfirmationNew.InsuranceToday.AppState.title
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 18) {
                    Image(uiImage: hCoreUIAssets.circularCheckmark.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                    hText(displayTitle, style: .title1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    hText(displayDate, style: .body)
                        .foregroundColor(hLabelColor.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 25)
            }
        }
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButtonFilled {
                    store.send(.setFocusedCrossSell(focusedCrossSell: nil))
                    store.send(.closeCrossSellingSigned)
                } content: {
                    hText(L10n.toolbarDoneButton)
                }
            }
            .padding(.bottom, 25)
            .slideUpAppearAnimation()
        }
        .sectionContainerStyle(.transparent)
    }
}

struct CrossSellingSignedPreviews: PreviewProvider {
    static var previews: some View {
        JourneyPreviewer(
            CrossSellingSigned.journey(
                startDate: Date()
            )
        )
        .mockState(ContractStore.self) { state in
            var newState = state

            newState.focusedCrossSell = .init(
                title: "Accident insurance",
                description: "",
                imageURL: URL(string: "https://giraffe.hedvig.com")!,
                blurHash: "",
                buttonText: "",
                typeOfContract: "SE_ACCIDENT"
            )

            return newState
        }
    }
}

extension CrossSellingSigned {
    public static func journey(startDate: Date?) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CrossSellingSigned(startDate: startDate)
        ) { action in
            if action == .closeCrossSellingSigned {
                DismissJourney()
            }
        }
        .onPresent {
            let store: ContractStore = globalPresentableStoreContainer.get()
            
            if let crossSell = store.state.focusedCrossSell {
                store.send(.didSignCrossSell(crossSell: crossSell))
            }
            
            store.send(.fetchContracts)
            store.send(.fetchContractBundles)
        }
        .addConfiguration { presenter in
            presenter.viewController.navigationItem.hidesBackButton = true
        }
    }
}
