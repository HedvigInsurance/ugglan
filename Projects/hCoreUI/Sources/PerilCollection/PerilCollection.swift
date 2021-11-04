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

    @hColorBuilder func background(configuration: Configuration) -> some hColor {
        if configuration.isPressed {
            hOverlayColor.pressed.opacity(0.5)
        } else {
            hBackgroundColor.tertiary
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            HStack(spacing: 8) {
                if let icon = peril.icon {
                    RemoteVectorIconView(icon: icon, backgroundFetch: true)
                        .frame(width: 24, height: 24)
                }
                VStack {
                    hText(peril.title, style: .headline)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding([.top, .bottom], 18)
        .padding([.trailing, .leading], 12)
        .frame(maxWidth: .infinity)
        .background(background(configuration: configuration))
        .cornerRadius(.defaultCornerRadius)
        .shadow(
            color: .black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
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

    public init(
        perils: [Perils],
        didTapPeril: @escaping (_ peril: Perils) -> Void
    ) {
        self.perils = perils
        self.didTapPeril = didTapPeril
    }

    public var body: some View {
        ForEach(perils.chunked(into: 2), id: \.id) { chunk in
            HStack {
                ForEach(chunk, id: \.title) { peril in
                    SwiftUI.Button {
                        didTapPeril(peril)
                    } label: {
                        EmptyView()
                    }
                    .buttonStyle(PerilButtonStyle(peril: peril))
                }
                if chunk.count == 1 {
                    Spacer()
                }
            }
            .padding(.bottom, 8)
        }
    }
}
