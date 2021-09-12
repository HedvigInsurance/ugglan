import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingSigned: View {
    @PresentableStore var store: ContractStore
    var startDate: Date?
    
    public init(startDate: Date? = nil) {
        self.startDate = startDate
    }

    var displayDate: String {
        guard let startDate = startDate, let localDateString = startDate.localDateString else {
            return ""
        }
                
        if Calendar.current.isDateInToday(startDate) {
            return L10n.PurchaseConfirmationNew.InsuranceToday.AppState.description
        } else {
            return L10n.PurchaseConfirmationNew.InsuranceActiveInFuture.AppState.description(localDateString)
        }
    }
    
    var displayTitle: String {
        let crossSellTitle = store.state.focusedCrossSell?.title.lowercased() ?? ""
        return L10n.PurchaseConfirmationNew.InsuranceToday.AppState.title(crossSellTitle)
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
                }.padding(.top, 25)
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
        ).mockState(ContractStore.self) { state in
            var newState = state
            
            newState.focusedCrossSell = .init(
                title: "Accident insurance",
                description: "",
                imageURL: URL(string: "https://giraffe.hedvig.com")!,
                blurHash: "",
                buttonText: ""
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
        }.onPresent {
            let store: ContractStore = globalPresentableStoreContainer.get()
            store.send(.fetchContracts)
            store.send(.fetchContractBundles)
            store.send(.fetchUpcomingAgreement)
        }.addConfiguration { presenter in
            presenter.viewController.navigationItem.hidesBackButton = true
        }
    }
}
