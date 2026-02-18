import SwiftUI
import hCore
import hCoreUI

public struct DeflectView: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    public var body: some View {
        hForm {
            hButton(.medium, .primary, content: .init(title: buttonTitle)) {
                action()
            }
            .hButtonTakeFullWidth(true)
        }
        .hFormTitle(
            title: .init(.standard, .body1, title),
            subTitle: .init(.standard, .body1, subtitle)
        )
        .padding(.padding16)
    }
}
