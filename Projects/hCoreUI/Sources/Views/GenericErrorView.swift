import SwiftUI
import hCore

public struct GenericErrorView: View {
    private let title: String?
    private let description: String?
    private let formPosition: ContentPosition?
    private let attachContentToBottom: Bool

    public init(
        title: String? = nil,
        description: String? = L10n.General.errorBody,
        formPosition: ContentPosition?,
        attachContentToBottom: Bool = false
    ) {
        self.title = title
        self.description = description
        self.formPosition = formPosition
        self.attachContentToBottom = attachContentToBottom
    }

    public var body: some View {
        StateView(
            type: .error,
            title: title ?? L10n.somethingWentWrong,
            bodyText: description,
            formPosition: formPosition,
            attachContentToBottom: attachContentToBottom
        )
    }
}

#Preview("Error") {
    GenericErrorView(
        formPosition: .center
    )
    .hStateViewButtonConfig(
        .init(
            actionButton: .init(buttonTitle: nil, buttonAction: {}),
            actionButtonAttachedToBottom:
                .init(
                    buttonTitle: "Extra button",
                    buttonAction: {}
                ),
            dismissButton:
                .init(
                    buttonTitle: "Close",
                    buttonAction: {}
                )
        )
    )
}

#Preview("ErrorAttachToBottom") {
    GenericErrorView(
        formPosition: .center,
        attachContentToBottom: true
    )
    .hStateViewButtonConfig(
        .init(
            actionButton: .init(buttonTitle: nil, buttonAction: {}),
            actionButtonAttachedToBottom:
                .init(
                    buttonTitle: "Extra button",
                    buttonAction: {}
                ),
            dismissButton:
                .init(
                    buttonTitle: "Close",
                    buttonAction: {}
                )
        )
    )
}

extension EnvironmentValues {
    @Entry public var hExtraTopPadding: Bool = false
}

extension View {
    public var hExtraTopPadding: some View {
        environment(\.hExtraTopPadding, true)
    }
}
