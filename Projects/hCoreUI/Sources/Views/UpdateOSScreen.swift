import hCore
import SwiftUI

public struct UpdateOSScreen: View {
    public init() {}

    public var body: some View {
        GenericErrorView(
            title: L10n.osVersionTooLowTitle,
            description: L10n.osVersionTooLowBody(UIDevice.current.systemVersion),
            formPosition: .center
        )
        .hStateViewButtonConfig(.init())
    }
}

#Preview {
    UpdateOSScreen()
}
