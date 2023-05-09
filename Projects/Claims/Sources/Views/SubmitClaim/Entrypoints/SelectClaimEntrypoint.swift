import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectClaimEntrypoint: View {
    @PresentableStore var store: SubmitClaimStore
    @State private var totalHeight = CGFloat.zero
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
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    //action
                } content: {
                    hText(L10n.generalContinueButton)
                        .foregroundColor(hLabelColor.primary).colorInvert()
                }
                .padding([.trailing, .leading], 16)
            }
        }
        //            PresentableStoreLens(
        //                SubmitClaimStore.self,
        //                getter: { state in
        //                    state.claimEntrypoints
        //                }
        //            ) { claimEntrypoint in
        //                hForm {
        //                    hText(L10n.claimTriagingTitle, style: .prominentTitle)
        //                        .multilineTextAlignment(.center)
        //                        .frame(maxWidth: .infinity, alignment: .center)
        //                        .padding([.trailing, .leading, .bottom], 16)

        //                    ZStack(alignment: .topLeading) {
        //                        ForEach(claimEntrypoint, id: \.id) { claimType in
        //
        //                            HStack {
        //                                hText(claimType.displayName, style: .body)
        //                                    .foregroundColor(hLabelColor.primary)
        //                                    .lineLimit(1)
        //                            }
        //                            .padding([.leading, .trailing], 16)
        //                            .padding([.top, .bottom], 8)
        //                            .background(hGrayscaleColor.one)
        //                            .cornerRadius(.smallCornerRadiusNew)

        //                            hPillFill(
        //                                text: claimType.displayName,
        //                                textColor: hLabelColor.primary,
        //                                backgroundColor: hGrayscaleColor.one)
        //                }
        //            }
        //        }
    }
    //                    .fixedSize(horizontal: false, vertical: true)
    //                    .lineLimit(nil)
    //                    .frame(maxWidth: .infinity, alignment: .leading)
    //                    hSection(claimEntrypoint, id: \.id) { claimType in
    //                        hRow {
    //                            hText(claimType.displayName, style: .body)
    //                                .foregroundColor(hLabelColor.primary)
    //                        }
    //                        .onTap {
    //                            store.send(
    //                                .commonClaimOriginSelected(commonClaim: ClaimsOrigin.commonClaims(id: claimType.id))
    //                            )
    //                        }
    //                    }
    //                    .withHeader {
    //                        hText(L10n.claimTriagingTitle, style: .prominentTitle)
    //                            .multilineTextAlignment(.center)
    //                            .frame(maxWidth: .infinity, alignment: .center)
    //                            .padding(.bottom, 30)
    //                    }
    //                }
    //
    //            }
    //            .presentableStoreLensAnimation(.easeInOut)
    //        }
    //    }

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
                    .padding([.leading, .trailing], 16)
                    .padding([.top, .bottom], 8)
                    .background(hGrayscaleColor.one)
                    .cornerRadius(.smallCornerRadiusNew)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(
                        .leading,
                        computeValue: { d in
                            if abs(width - d.width) > g.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if claimType == self.tags?.last! {
                                width = 0  //last item
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                    )
                    .alignmentGuide(
                        .top,
                        computeValue: { d in
                            let result = height
                            if claimType == self.tags?.last! {
                                height = 0  // last item
                            }
                            return result
                        }
                    )
                }
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
}
