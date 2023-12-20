import SwiftUI
import hCore
import hGraphQL

public struct UpdateAppScreen: View {
    let onSelected: () -> Void
    
    public init(
        onSelected: @escaping () -> Void
    ) {
        self.onSelected = onSelected
    }
    
    public var body: some View {
        GenericErrorView(
            title: L10n.embarkUpdateAppTitle,
            description: L10n.embarkUpdateAppBody,
            buttons:
                    .init(
                        actionButton:
                                .init(
                                    buttonTitle: L10n.embarkUpdateAppButton,
                                    buttonAction: {
                                        UIApplication.shared.open(Environment.current.appStoreURL)
                                        onSelected()
                                    }),
                        dismissButton:
                                .init(
                                    buttonTitle: L10n.generalCloseButton,
                                    buttonAction: {
                                        onSelected()
                                    }))
        )
    }
}

#Preview{
    UpdateAppScreen(onSelected: {})
}
