import SwiftUI
import hCore

extension View {
    public func showInfoScreen(text: Binding<String?>, dismissButtonTitle: String) -> some View {
        detent(item: text, transitionType: .detent(style: [.height])) { text in
            InfoScreenWrapper(text: text, dismissButtonTitle: dismissButtonTitle)
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String {
        self
    }
}

struct InfoScreenWrapper: View {
    let text: String
    let dismissButtonTitle: String
    let router = Router()
    var body: some View {
        RouterHost(router: router, tracking: self) {
            InfoScreen(text: text, dismissButtonTitle: dismissButtonTitle, contentPosition: .compact) {
                router.dismiss()
            }
        }
    }
}

extension InfoScreenWrapper: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: TrackingViewNameProtocol.self)
    }
}

public struct InfoScreen: View {
    let text: String
    let dismissButtonTitle: String
    let onClickButton: () -> Void
    let contentPosition: ContentPosition

    public init(
        text: String,
        dismissButtonTitle: String,
        contentPosition: ContentPosition = .center,
        onClickButton: @escaping () -> Void
    ) {
        self.text = text
        self.dismissButtonTitle = dismissButtonTitle
        self.contentPosition = contentPosition
        self.onClickButton = onClickButton
    }

    public var body: some View {
        hForm {
            StateView(
                type: .information,
                title: text,
                bodyText: nil
            )
            .padding(.bottom, .padding16)
        }
        .hFormContentPosition(contentPosition)
        .hFormAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: dismissButtonTitle),
                    {
                        onClickButton()
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}
