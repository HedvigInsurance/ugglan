import SwiftUI
import hCore
import hGraphQL

public struct UpdateOSScreen: View {

    public init() {}

    public var body: some View {
        GenericErrorView(
            title: L10n.osVersionTooLowTitle,
            description: L10n.osVersionTooLowBody(UIDevice.current.systemVersion),
            buttons: .init()
        )
    }
}

#Preview{
    UpdateOSScreen()
}
