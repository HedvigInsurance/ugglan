import Presentation
import SwiftUI
import TagKit
import hAnalytics
import hCore
import hCoreUI

public struct SelectClaimEntrypointOld: View {
    @PresentableStore var store: SubmitClaimStore
    @State private var height = CGFloat.zero
    @State private var tmpHeight = CGFloat.zero
    @State var selectedClaimType: String? = nil
    let entrypointGroupId: String?

    public init(
        entrypointGroupId: String? = nil
    ) {
        self.entrypointGroupId = entrypointGroupId
        store.send(.fetchClaimEntrypointsForSelection(entrypointGroupId: entrypointGroupId))
    }

    public var body: some View {
        LoadingViewWithContent(.startClaim) {
            LoadingViewWithContent(.fetchClaimEntrypoints) {
                hForm {
                    PresentableStoreLens(
                        SubmitClaimStore.self,
                        getter: { state in
                            state.claimEntrypoints
                        }
                    ) { claimEntrypoint in
                        entrypointList(claimEntrypoint: claimEntrypoint)
                    }
                }
            }
        }
    }

    public func entrypointList(claimEntrypoint: [ClaimEntryPointResponseModel]) -> some View {
        hSection(claimEntrypoint, id: \.id) { claimType in
            hRow {
                hText(claimType.displayName, style: .body)
                    .foregroundColor(hLabelColorNew.primary)
            }
            .onTap {
                store.send(
                    .startClaimRequest(
                        entrypointId: claimType.id,
                        entrypointOptionId: nil
                    )
                )
            }
        }
        .withHeader {
            hText(L10n.claimTriagingTitle, style: .prominentTitle)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 30)
        }
        .hUseNewStyle
        .presentableStoreLensAnimation(.easeInOut)
    }

}
