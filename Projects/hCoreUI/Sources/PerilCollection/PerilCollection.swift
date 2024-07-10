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
                AccordionView(peril: peril)
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
