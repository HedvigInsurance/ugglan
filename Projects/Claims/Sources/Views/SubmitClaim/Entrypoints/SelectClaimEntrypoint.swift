import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectClaimEntrypoint: View {
    @PresentableStore var store: SubmitClaimStore
    @State private var height = CGFloat.zero
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
                    .padding([.trailing, .leading], 16)
                    .padding([.bottom], 100)

                VStack {
                    GeometryReader { geometry in
                        self.generateContent(in: geometry)
                            .background(viewHeight(for: $height))
                    }
                    .frame(height: height)
                    .padding([.trailing, .leading], 16)
                }
                hButton.LargeButtonFilled {
                    store.send(
                        .commonClaimOriginSelected(commonClaim: ClaimsOrigin.commonClaims(id: selectedClaimType))
                    )
                } content: {
                    hText(L10n.generalContinueButton)
                        .foregroundColor(hLabelColor.primary).colorInvert()
                }
                .padding([.trailing, .leading], 16)
            }
        }
        //        .navigationTitle("Bellmansgatan 19A")
    }

    func generateContent(in geometry: GeometryProxy) -> some View {
        var bounds = CGSize.zero

        return ZStack {
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
                    .alignmentGuide(VerticalAlignment.center) { dimension in
                        let result = bounds.height

                        if let firstItem = claimEntrypoint.first, claimType == firstItem {
                            bounds.height = 0
                        }
                        return result
                    }
                    .alignmentGuide(HorizontalAlignment.center) { dimension in
                        if abs(bounds.width - dimension.width) > geometry.size.width {
                            bounds.width = 0
                            bounds.height -= dimension.height
                        }

                        let result = bounds.width

                        if let firstItem = claimEntrypoint.first, claimType == firstItem {
                            bounds.width = 0
                        } else {
                            bounds.width -= dimension.width
                        }
                        return result
                    }
                }
            }
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

    private func viewHeight(for binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)

            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
