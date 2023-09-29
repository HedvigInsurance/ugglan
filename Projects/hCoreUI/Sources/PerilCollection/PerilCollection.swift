import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
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

    @hColorBuilder func background(configuration: Configuration) -> some hColor {
        if configuration.isPressed {
            hOverlayColorOld.pressed.opacity(0.5)
        } else {
            hBackgroundColor.primary
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 11) {
            HStack(spacing: 8) {
                if let icon = peril.icon {
                    RemoteVectorIconView(icon: icon, backgroundFetch: true)
                        .frame(width: 24, height: 24)
                } else if let color = peril.color {
                    Circle().fill(Color(hexString: color))
                        .frame(width: 24, height: 24)
                }
                hText(peril.title, style: .title3)
                    .lineLimit(1)
                Spacer()
                Image(
                    uiImage: selectedPerils.contains(peril)
                        ? hCoreUIAssets.minusSmall.image : hCoreUIAssets.plusSmall.image
                )
                .transition(.opacity.animation(.easeOut))
            }
            .padding(.vertical, 13)

            if selectedPerils.contains(peril) {
                VStack(alignment: .leading, spacing: 12) {
                    hText(peril.description, style: .footnote)
                        .padding(.bottom, 12)
                    ForEach(Array(peril.covered.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 8) {
                            hText(String(format: "%02d", index + 1), style: .footnote)
                                .foregroundColor(hTextColor.tertiary)
                            hText(item, style: .footnote)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
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
                    didTapPeril(peril)
                    if let index = self.selectedPerils.firstIndex(where: { $0 == peril }) {
                        selectedPerils.remove(at: index)
                    } else {
                        selectedPerils.append(peril)
                    }
                } label: {
                    EmptyView()
                }
                .buttonStyle(PerilButtonStyle(peril: peril, selectedPerils: selectedPerils))
            }
        }
    }
}
struct PerilCollection_Previews: PreviewProvider {
    static var previews: some View {
        let perils: [Perils] =
            [
                .init(
                    fragment: .init(
                        covered: [],
                        description: "DESC",
                        exceptions: [],
                        id: "1",
                        info: "info",
                        title: "title"
                    )
                ),
                .init(
                    fragment: .init(
                        covered: [],
                        description: "DESC",
                        exceptions: [],
                        id: "2",
                        info: "info",
                        title: "title2"
                    )
                ),
            ]
        PerilCollection(
            perils: perils
        ) { peril in

        }
    }
}
