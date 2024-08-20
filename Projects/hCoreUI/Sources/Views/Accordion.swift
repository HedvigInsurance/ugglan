import SwiftUI
import hCore

public struct AccordionView: View {
    let peril: Perils?
    let title: String
    let description: String
    @State var extended = false

    public init(
        peril: Perils
    ) {
        self.peril = peril
        self.title = peril.title
        self.description = peril.description
    }

    public init(
        title: String,
        description: String
    ) {
        self.title = title
        self.description = description
        self.peril = nil
    }

    public var body: some View {
        SwiftUI.Button {
            withAnimation {
                extended.toggle()
            }
        } label: {
            EmptyView()
        }
        .buttonStyle(
            AccordionButtonStyle(
                peril: peril,
                title: title,
                description: description,
                extended: $extended
            )
        )
        .modifier(
            BackgorundColorAnimation(
                animationTrigger: $extended,
                color: hSurfaceColor.Opaque.primary,
                animationColor: hSurfaceColor.Opaque.secondary
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
    }
}

struct AccordionButtonStyle: SwiftUI.ButtonStyle {
    var peril: Perils?
    let title: String
    let description: String

    @Binding var extended: Bool
    @Environment(\.hFieldSize) var fieldSize

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 11) {
            HStack(spacing: 8) {
                if let color = peril?.color {
                    Circle().fill(Color(hexString: color))
                        .frame(width: fieldSize == .small ? 20 : 24, height: fieldSize == .small ? 20 : 24)
                        .padding(.horizontal, .padding4)
                }
                hText(title, style: fieldSize == .large ? .heading2 : .heading1)
                    .lineLimit(1)
                Spacer()
                ZStack {
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .transition(.opacity.animation(.easeOut))
                    .rotationEffect(extended ? Angle(degrees: 360) : Angle(degrees: 270))
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .transition(.opacity.animation(.easeOut))
                    .rotationEffect(extended ? Angle(degrees: 360) : Angle(degrees: 180))
                }
            }

            if extended {
                VStack(alignment: .leading, spacing: 12) {
                    hText(description, style: peril != nil ? .label : .body1)
                        .padding(.bottom, .padding12)
                    if let perilCover = peril?.covered {
                        ForEach(Array(perilCover.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 8) {
                                hText(String(format: "%02d", index + 1), style: .label)
                                    .foregroundColor(hTextColor.Opaque.tertiary)
                                hText(item, style: .label)
                            }
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, .padding32)
                .padding(.bottom, .padding24)
            }
        }
        .padding(.horizontal, .padding16)
        .padding(.top, fieldSize == .small ? 15 : .padding16)
        .padding(.bottom, fieldSize == .small ? 17 : 18)
        .contentShape(Rectangle())

    }
}

#Preview{
    hSection {
        AccordionView(
            title: "Label",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent suscipit metus a porttitor pulvinar. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Phasellus ac tristique sem. Praesent sit amet nisi fermentum, dignissim est nec, tristique ante. Aliquam aliquet vestibulum nulla a congue."
        )
    }
}
