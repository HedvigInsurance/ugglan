import Presentation
import SwiftUI
import TagKit
import hCore
import hCoreUI

public struct SelectClaimEntrypoint: View {
    @PresentableStore var store: SubmitClaimStore
    @State private var height = CGFloat.zero
    @State private var tmpHeight = CGFloat.zero
    @State var selectedClaimType: String = ""

    public init(
        entrypointGroupId: String
    ) {
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
                hText(L10n.claimTriagingTitle, style: .prominentTitle)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.trailing, .leading], 16)
                    .padding([.bottom], 100)

                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.claimEntrypoints
                    }
                ) { claimEntrypoint in

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
        }
        //        .navigationTitle("Bellmansgatan 19A")
    }

    @hColorBuilder
    func retColor(claimId: String) -> some hColor {
        if selectedClaimType == claimId {
            hTintColorNew.green50
        } else {
            hGrayscaleColorNew.greyScale100
        }
    }
}
