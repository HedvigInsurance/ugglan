import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct ContractDetailErrorScreen: View {
    @PresentableStore var store: ContractStore

    public init() {}

    public var body: some View {
        hForm {
            VStack {
                Spacer()
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)
                    .padding(.bottom, 8)

                hText(L10n.HomeTab.errorTitle, style: .body)
                    .foregroundColor(hTextColor.primary)

                hText(L10n.contractDetailsError, style: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hTextColor.secondary)
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButton(type: .primary) {
                    store.send(.dismisscontractDetailNavigation)
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                }
                .padding(.bottom, 4)

                hButton.LargeButton(type: .ghost) {
                    store.send(.goToFreeTextChat)
                } content: {
                    hText(L10n.openChat, style: .body)
                }
            }
            .padding([.leading, .trailing, .bottom], 16)
        }
    }
}

extension ContractDetailErrorScreen {
    public var journey: some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self
        ) { action in
            if case .goToFreeTextChat = action {
                DismissJourney()
            } else if case .dismisscontractDetailNavigation = action {
                DismissJourney()
            }
        }
    }
}
