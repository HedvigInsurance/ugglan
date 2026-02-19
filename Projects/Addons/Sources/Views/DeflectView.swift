import SwiftUI
import hCore
import hCoreUI

public struct DeflectView: View {
    private let contractId: String
    private let title: String
    private let subtitle: String
    private let buttonTitle: String
    private let navigateToChangeTier: () -> Void
    private let router = Router()

    init(deflect: AddonDeflect) {
        contractId = deflect.contractId
        title = deflect.pageTitle
        subtitle = deflect.pageDescription
        buttonTitle =
            switch (deflect.type) {
            case .upgradeTier: L10n.changeTierButtonTitle
            }
        navigateToChangeTier = {
            switch deflect.type {
            case .upgradeTier:
                NotificationCenter.default.post(name: .openChangeTier, object: deflect.contractId)
            }
        }
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding64) {
                    VStack(spacing: .padding16) {
                        hCoreUIAssets.infoFilled.swiftUIImage
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(hSignalColor.Blue.element)

                        VStack(spacing: 0) {
                            hText(title).foregroundColor(hTextColor.Opaque.primary)
                            hText(subtitle).foregroundColor(hTextColor.Translucent.secondary)
                        }
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, .padding8)

                    VStack(spacing: .padding8) {
                        hButton(.large, .primary, content: .init(title: buttonTitle)) { [weak router] in
                            router?.dismiss()
                            navigateToChangeTier()
                        }
                        hButton(.large, .secondary, content: .init(title: "Avbryt")) { [weak router] in
                            router?.dismiss()
                        }
                    }
                }
                .padding(.top, .padding56)
                .padding(.bottom, .padding16)
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .embededInNavigation(router: router, options: [.navigationBarHidden], tracking: self)
    }
}
extension DeflectView: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: DeflectView.self)
    }
}

#Preview {
    DeflectView(deflect: testDeflectUpgradeTier)
}
