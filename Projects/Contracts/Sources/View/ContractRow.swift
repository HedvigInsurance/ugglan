import Combine
import Flow
import Form
import Foundation
import Hero
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct StatusPill: View {
    var text: String

    var body: some View {
        VStack {
            hText(text.uppercased(), style: .caption2)
        }
        .padding([.top, .bottom], 5)
        .padding([.leading, .trailing], 8)
        .background(hTintColor.yellowOne)
        .cornerRadius(4)
    }
}

struct DetailPill: View {
    var text: String

    var body: some View {
        VStack {
            hText(text.uppercased(), style: .caption2)
        }
        .padding([.top, .bottom], 5)
        .padding([.leading, .trailing], 8)
        .background(hBackgroundColor.primary.opacity(0.5))
        .cornerRadius(4)
    }
}

struct ContractRowChevron: View {
    @SwiftUI.Environment(\.isEnabled) var isEnabled

    var body: some View {
        if isEnabled {
            Image(uiImage: hCoreUIAssets.chevronRight.image)
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

struct ContractRowButtonStyle: SwiftUI.ButtonStyle {
    let contract: Contract

    @ViewBuilder func backgroundColor(configuration: Configuration) -> some View {
        if configuration.isPressed {
            hOverlayColor.pressed.opacity(0.3)
        }

        Color.clear
    }

    @ViewBuilder var gradientView: some View {
        if let gradientOption = contract.gradientOption {
            hGradientView(gradientOption: .init(gradientOption: gradientOption), shouldShowGradient: true)
        } else {
            hGrayscaleColor.one
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                ForEach(contract.statusPills, id: \.self) { pill in
                    StatusPill(text: pill)
                }
                Spacer()
                Image(uiImage: hCoreUIAssets.symbol.image.withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Spacer()
            HStack {
                hText(contract.displayName, style: .title2)
                Spacer()
            }
            HStack {
                ForEach(contract.detailPills, id: \.self) { pill in
                    if contract.gradientOption == nil {
                        DetailPill(text: pill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(hLabelColor.primary, lineWidth: 1)
                            )
                    } else {
                        DetailPill(text: pill)
                    }
                }
                Spacer()
                ContractRowChevron()
            }
        }
        .padding(16)
        .frame(minHeight: 200)
        .background(
            backgroundColor(configuration: configuration)
        )
        .background(
            gradientView
        )
        .cornerRadius(.defaultCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .stroke(hSeparatorColor.separator, lineWidth: .hairlineWidth)
        )
    }
}

struct ContractRow: View {
    @PresentableStore var store: ContractStore
    @State var frameWidth: CGFloat = 0

    var contract: Contract
    var allowDetailNavigation = true

    var body: some View {
        SwiftUI.Button {
            store.send(.openDetail(contract: contract))
        } label: {
            EmptyView()
        }
        .disabled(!allowDetailNavigation)
        .buttonStyle(ContractRowButtonStyle(contract: contract))
        .background(
            GeometryReader { geo in
                Color.clear.onReceive(Just(geo.size.width)) { width in
                    self.frameWidth = width
                }
            }
        )
        .enableHero(
            "ContractRow_\(contract.id)",
            modifiers: [
                .spring(stiffness: 250, damping: 25),
                .when(
                    { context -> Bool in !context.isMatched },
                    [
                        .init(applyFunction: { (state: inout HeroTargetState) in
                            state.append(
                                .translate(
                                    x: -frameWidth
                                        * 1.3,
                                    y: 0,
                                    z: 0
                                )
                            )
                        })
                    ]
                ),
            ]
        )
    }
}
