import SwiftUI
import hCore

extension View {
    public func showInfoScreen(text: Binding<String?>, dismissButtonTitle: String) -> some View {
        self.detent(item: text, style: [.height]) { text in
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
        return .init(describing: TrackingViewNameProtocol.self)
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
                hButton.LargeButton(type: .ghost) {
                    onClickButton()
                } content: {
                    hText(dismissButtonTitle)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.vertical, .padding16)
        }
    }
}
