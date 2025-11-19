import SwiftUI
import hCore
import hCoreUI

struct CrosssSellStackComponent: View {
    let crossSells: [CrossSell]
    let showDiscount: Bool
    let withHeader: Bool
    var body: some View {
        if withHeader {
            hSection {
                VStack(spacing: .padding16) {
                    hasDiscountView
                    ForEach(crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell)
                            .transition(.slide)
                    }
                }
            }
            .withHeader(
                title: L10n.InsuranceTab.CrossSells.title
            )
            .sectionContainerStyle(.transparent)
            .transition(.slide)
        } else {
            hSection {
                VStack(spacing: .padding16) {
                    ForEach(crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell)
                            .transition(.slide)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .transition(.slide)
        }
    }

    @ViewBuilder
    private var hasDiscountView: some View {
        if showDiscount {
            HStack {
                hCoreUIAssets.campaign.view.foregroundColor(hSignalColor.Green.element)
                    .rotate()
                    .frame(width: 17, height: 17)
                    .modifier(
                        ExpandingContentModifier(expandingContent: {
                            hText(L10n.insurancesCrossSellDiscountsAvailable, style: .label)
                                .foregroundColor(hSignalColor.Green.text)
                                .padding(.trailing, .padding4)
                        })
                    )
                    .padding(.padding8)
                    .background(hHighlightColor.Green.fillOne)
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
                Spacer()
            }
        }
    }
}

#Preview {
    CrosssSellStackComponent(
        crossSells: [
            .init(
                id: "id",
                title: "title",
                description: "long description that goes long way",
                imageUrl: nil,
                buttonDescription: "button"
            )
        ],
        showDiscount: true,
        withHeader: true
    )
}

public struct ExpandingContentModifier<AddedView: View>: ViewModifier {
    @ViewBuilder var expandingContent: () -> AddedView
    let spacing: CGFloat
    let delay: Float
    //    @State var expanded = false
    @StateObject var vm = AnimationViewModel()

    public init(
        spacing: CGFloat = .padding8,
        delay: Float = 1,
        @ViewBuilder expandingContent: @escaping () -> AddedView
    ) {
        self.spacing = spacing
        self.delay = delay
        self.expandingContent = expandingContent
    }

    public func body(content: Content) -> some View {
        HStack(spacing: spacing) {
            content
            if vm.expanded {
                expandingContent()
            }
        }
        .onAppear {
            Task {
                vm.expanded = false
                try? await Task.sleep(seconds: delay)
                let animation = Animation.easeInOut(duration: 1)
                withAnimation(animation) {
                    vm.expanded = true
                }
            }
        }
    }
}

class AnimationViewModel: ObservableObject {
    @Published var expanded: Bool = false
}
