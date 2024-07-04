import Foundation
import SwiftUI
import hCore
import hGraphQL

public struct PerilCollection: View {
    public var perils: [Perils]
    @SwiftUI.Environment(\.hFieldSize) var fieldSize

    public init(
        perils: [Perils]
    ) {
        self.perils = perils
    }

    public var body: some View {
        ForEach(perils, id: \.title) { peril in
            hSection {
                PerilView(peril: peril)
            }
        }
    }
}

struct PerilView: View {
    let peril: Perils
    @State var extended = false
    var body: some View {
        SwiftUI.Button {
            withAnimation {
                extended.toggle()
            }
        } label: {
            EmptyView()
        }
        .buttonStyle(
            PerilButtonStyle(
                peril: peril,
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
    }
}

struct PerilButtonStyle: SwiftUI.ButtonStyle {
    var peril: Perils
    @State var nbOfPerils = 1
    @Binding var extended: Bool
    @SwiftUI.Environment(\.hFieldSize) var fieldSize

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 11) {
            HStack(spacing: 8) {
                if let color = peril.color {
                    Circle().fill(Color(hexString: color))
                        .frame(width: fieldSize == .small ? 20 : 24, height: fieldSize == .small ? 20 : 24)
                        .padding(.horizontal, .padding4)
                }
                hText(peril.title, style: fieldSize == .small ? .body1 : .heading2)
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
                    hText(peril.description, style: .footnote)
                        .padding(.bottom, .padding12)
                    ForEach(Array(peril.covered.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 8) {
                            hText(String(format: "%02d", index + 1), style: .footnote)
                                .foregroundColor(hTextColor.Opaque.tertiary)
                            hText(item, style: .footnote)
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

struct PerilCollection_Previews: PreviewProvider {
    static var previews: some View {
        let perils: [Perils] =
            [
                .init(
                    id: "1",
                    title: "title",
                    description: "lkflihf uhreuidhf iwureahriur ekfshiuf erhfw iueherfuihgfeuihfgrui fruhfiuehf",
                    info: nil,
                    color: nil,
                    covered: []
                )
            ]
        VStack {
            PerilCollection(
                perils: perils
            )
            .hFieldSize(.small)

            PerilCollection(
                perils: perils
            )
            .hFieldSize(.large)
        }
    }
}
