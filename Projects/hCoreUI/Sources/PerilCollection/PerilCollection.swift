import Foundation
import SwiftUI
import hCore
import hGraphQL

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size)
            .map {
                Array(self[$0..<Swift.min($0 + size, count)])
            }
    }
}

struct PerilButtonStyle: SwiftUI.ButtonStyle {
    var peril: Perils
    var selectedPerils: [Perils]
    @State var nbOfPerils = 1
    @Binding var fieldIsClicked: Bool
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
                    .rotationEffect(selectedPerils.contains(peril) ? Angle(degrees: 360) : Angle(degrees: 270))
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .transition(.opacity.animation(.easeOut))
                    .rotationEffect(selectedPerils.contains(peril) ? Angle(degrees: 360) : Angle(degrees: 180))
                }
            }

            if selectedPerils.contains(peril) {
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
        .background(getBackgroundColor)
    }

    @hColorBuilder
    var getBackgroundColor: some hColor {
        if fieldIsClicked {
            hSurfaceColor.Opaque.secondary
        } else {
            hBackgroundColor.clear
        }
    }
}

extension Array where Element == Perils {
    var id: String {
        self.map { peril in peril.title }.joined(separator: "")
    }
}

public struct PerilCollection: View {
    public var perils: [Perils]
    public var didTapPeril: (_ peril: Perils) -> Void
    @State var selectedPerils: [Perils] = []
    @State var fieldIsClicked = false
    @SwiftUI.Environment(\.hFieldSize) var fieldSize

    public init(
        perils: [Perils],
        didTapPeril: @escaping (_ peril: Perils) -> Void
    ) {
        self.perils = perils
        self.didTapPeril = didTapPeril
    }

    public var body: some View {
        ForEach(perils, id: \.title) { peril in
            hSection {
                SwiftUI.Button {
                    withAnimation(.easeIn(duration: 1.0)) {
                        fieldIsClicked = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            fieldIsClicked = false
                        }
                    }
                    didTapPeril(peril)
                    if let index = self.selectedPerils.firstIndex(where: { $0 == peril }) {
                        selectedPerils.remove(at: index)
                    } else {
                        selectedPerils.append(peril)
                    }
                } label: {
                    EmptyView()
                }
                .buttonStyle(
                    PerilButtonStyle(
                        peril: peril,
                        selectedPerils: selectedPerils,
                        fieldIsClicked: $fieldIsClicked
                    )
                )
            }
        }
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
                    color: "121212",
                    covered: [],
                    exceptions: []
                )
            ]
        VStack {
            PerilCollection(
                perils: perils,
                didTapPeril: { peril in

                }
            )
            .hFieldSize(.small)

            PerilCollection(
                perils: perils,
                didTapPeril: { _ in

                }
            )
            .hFieldSize(.large)
        }
    }
}
