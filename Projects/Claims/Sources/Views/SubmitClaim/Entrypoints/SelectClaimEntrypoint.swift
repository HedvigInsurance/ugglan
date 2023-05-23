import Presentation
import SwiftUI
import TagKit
import hAnalytics
import hCore
import hCoreUI

public struct SelectClaimEntrypoint: View {
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

    func entrypointToStringArray(input: [ClaimEntryPointResponseModel]) -> [String] {
        var arr: [String] = []
        for i in input {
            arr.append(i.displayName)
        }
        return arr
    }

    func mapNametoId(input: [ClaimEntryPointResponseModel]) -> String {
        for claimType in input {
            if claimType.displayName == selectedClaimType {
                return claimType.id
            }
        }
        return ""
    }

    public var body: some View {
        LoadingViewWithContent(.fetchClaimEntrypoints) {
            hForm {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.claimEntrypoints
                    }
                ) { claimEntrypoint in
                    if hAnalyticsExperiment.claimsTriaging {
                        entrypointPills(claimEntrypoint: claimEntrypoint)
                    } else {
                        entrypointList(claimEntrypoint: claimEntrypoint)
                    }
                }
            }
        }
    }

    @ViewBuilder
    public func entrypointPills(claimEntrypoint: [ClaimEntryPointResponseModel]) -> some View {

        hText(L10n.claimTriagingTitle, style: .prominentTitle)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding([.trailing, .leading], 16)
            .padding([.bottom, .top], 82)

        let arrayList = entrypointToStringArray(input: claimEntrypoint)

        TagList(tags: arrayList) { tag in
            HStack {
                hText(tag, style: .body)
                    .foregroundColor(hLabelColor.primary)
                    .lineLimit(1)
            }
            .onAppear {
                if selectedClaimType == "" {
                    selectedClaimType = claimEntrypoint.last?.displayName ?? ""
                }
            }
            .onTapGesture {
                withAnimation {
                    selectedClaimType = tag
                }
            }
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 8)
            .background(
                Squircle.default()
                    .fill(retColor(claimId: tag))
                    .hShadow()
            )

        }
        .padding([.leading, .trailing], 16)

        if let selectedClaimType = selectedClaimType {
            hButton.LargeButtonFilled {
                store.send(
                    .commonClaimOriginSelected(
                        commonClaim: ClaimsOrigin.commonClaims(id: mapNametoId(input: claimEntrypoint))
                    )
                )
            } content: {
                hText(L10n.generalContinueButton)
                    .foregroundColor(hLabelColor.primary).colorInvert()
            }
            .padding([.trailing, .leading], 16)
        }
    }

    public func entrypointList(claimEntrypoint: [ClaimEntryPointResponseModel]) -> some View {
        hSection(claimEntrypoint, id: \.id) { claimType in
            hRow {
                hText(claimType.displayName, style: .body)
                    .foregroundColor(hLabelColor.primary)
            }
            .onTap {
                store.send(
                    .commonClaimOriginSelected(commonClaim: ClaimsOrigin.commonClaims(id: claimType.id))
                )
            }
        }
        .withHeader {
            hText(L10n.claimTriagingTitle, style: .prominentTitle)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 30)
        }
        .presentableStoreLensAnimation(.easeInOut)
    }

    @hColorBuilder
    func retColor(claimId: String) -> some hColor {
        if selectedClaimType == claimId {
            hGreenColorNew.green50
        } else {
            hGrayscaleColorNew.greyScale100
        }
    }
}
