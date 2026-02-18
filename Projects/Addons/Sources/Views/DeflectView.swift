import SwiftUI
import hCore
import hCoreUI

public struct DeflectView: View {
    private let contractId: String
    private let title: String
    private let subtitle: String
    private let buttonTitle: String
    private let navigateToChangeTier: () -> Void
    private let onDismiss: () -> Void

    init(deflect: AddonDeflect, onDismiss: @escaping () -> Void) {
        contractId = deflect.contractId
        title = deflect.pageTitle
        subtitle = deflect.pageDescription
        buttonTitle =
            switch (deflect.type) {
            case .upgradeTier: "Ändra skyddnivå!"
            }
        navigateToChangeTier = {
            switch deflect.type {
            case .upgradeTier:
                NotificationCenter.default.post(name: .openChangeTier, object: deflect.contractId)
            }
        }
        self.onDismiss = onDismiss
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                hCoreUIAssets.infoFilled.swiftUIImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(hSignalColor.Blue.element)

                VStack {
                    hText(title).foregroundColor(hTextColor.Opaque.primary)
                    hText(subtitle).foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .padding(.horizontal, .padding24)
            .padding(.vertical, .padding32)

            VStack(spacing: .padding8) {
                hButton(.large, .primary, content: .init(title: buttonTitle)) {
                    onDismiss()
                    navigateToChangeTier()
                }
                hButton(.large, .secondary, content: .init(title: "Avbryt")) {
                    onDismiss()
                }
            }
            .padding(.horizontal, .padding16)
            .padding(.vertical, .padding32)
        }
        .hButtonTakeFullWidth(true)
    }
}

#Preview {
    DeflectView(
        deflect: .init(
            contractId: "cId",
            pageTitle: "Du behöver en högre skyddnivå",
            pageDescription: """
                Våra tilläggsförsäkringar går inte att
                kombinera med trafikförsäkring. Välj en
                högre skyddsnivå för att fortsätta.
                """,
            type: .upgradeTier
        )
    ) {}
}
