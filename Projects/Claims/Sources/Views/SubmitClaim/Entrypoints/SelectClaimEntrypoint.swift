import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectClaimEntrypoint: View {
    @PresentableStore var store: SubmitClaimStore
    @State private var totalHeight = CGFloat.zero
    @State var selectedClaimType: String = ""
    var tags: [ClaimEntryPointResponseModel]?

    public init(
        entrypointGroupId: String
    ) {
        store.send(.fetchClaimEntrypointsForSelection(entrypointGroupId: entrypointGroupId))
    }
    public var body: some View {
        LoadingViewWithContent(.fetchClaimEntrypoints) {
            hForm {
                hText(L10n.claimTriagingTitle, style: .prominentTitle)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.trailing, .leading, .bottom], 16)

                VStack {
                    GeometryReader { geometry in
                        self.generateContent(in: geometry)
                    }
                }
                .frame(height: totalHeight)
                .padding([.leading, .trailing], 16)

                VStack {

                    hButton.LargeButtonFilled {
                        store.send(
                            .commonClaimOriginSelected(commonClaim: ClaimsOrigin.commonClaims(id: selectedClaimType))
                        )
                    } content: {
                        hText(L10n.generalContinueButton)
                            .foregroundColor(hLabelColor.primary).colorInvert()
                    }
                }
                .padding([.trailing, .leading], 16)
                .padding(.top, (totalHeight))
            }
        }
        .navigationTitle("Bellmansgatan 19A")
    }

    func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.claimEntrypoints
                }
            ) { claimEntrypoint in
                ForEach(claimEntrypoint, id: \.id) { claimType in
                    HStack {
                        hText(claimType.displayName, style: .body)
                            .foregroundColor(hLabelColor.primary)
                            .lineLimit(1)
                    }
                    .onTapGesture {
                        let entrypointId = claimType.id
                        withAnimation {
                            if selectedClaimType == entrypointId {
                                selectedClaimType = ""
                            } else {
                                selectedClaimType = entrypointId
                            }
                        }
                    }
                    .padding([.leading, .trailing], 16)
                    .padding([.top, .bottom], 8)
                    .background(
                        Squircle.default()
                            .fill(retColor(claimId: claimType.id))
                            .hShadow()
                    )
                    .padding([.trailing, .bottom], 8)
                    .alignmentGuide(
                        .leading,
                        computeValue: { d in
                            if abs(width - d.width) > g.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if claimType == self.tags?.last! {
                                width = 0
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                    )
                    .padding(.top, 16)
                    .alignmentGuide(
                        .top,
                        computeValue: { d in
                            let result = height
                            if claimType == self.tags?.last! {
                                height = 0
                            }
                            return result  // 0 doesn't start at same place always
                        }
                    )
                }
                //                hText("Test")
                //                    .alignmentGuide(
                //                        .top,
                //                        computeValue: { d in
                //                            let result = height
                ////                            if claimType == self.tags?.last! {
                ////                                height = 0
                ////                            }
                //                            return height // 0 doesn't start at same place always
                //                        }
                //                    )
                ////                .padding([.trailing, .leading, .top], 16)
                ////                .padding([.top], 16)
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
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
