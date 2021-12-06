import Apollo
import Combine
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit

public struct PreviewJourney<InnerJourney: JourneyPresentation>: JourneyPresentation {
    public var onDismiss: (Error?) -> Void

    public var style: PresentationStyle

    public var options: PresentationOptions

    public var transform: (InnerJourney.P.Result) -> InnerJourney.P.Result

    public var configure: (JourneyPresenter<P>) -> Void

    public let presentable: InnerJourney.P

    public init(
        options: PresentationOptions,
        @JourneyBuilder _ content: @escaping () -> InnerJourney
    ) {
        let presentation = content()
        self.presentable = presentation.presentable
        self.style = presentation.style
        self.options = options
        self.transform = presentation.transform
        self.configure = presentation.configure
        self.onDismiss = presentation.onDismiss
    }
}

public struct JourneyPreviewer<Journey: JourneyPresentation>: UIViewControllerRepresentable {
    let journey: Journey

    public init(
        _ journey: Journey
    ) {
        self.journey = journey

        let store = ApolloStore()
        let client = ApolloClient(url: URL(string: "https://graphql.dev.hedvigit.com/graphql")!)

        Dependencies.shared.add(
            module: Module { () -> ApolloClient in
                client
            }
        )

        Dependencies.shared.add(
            module: Module { () -> ApolloStore in
                store
            }
        )
    }

    public func makeUIViewController(context: Context) -> some UIViewController {
        let navigationController = UINavigationController()

        var options = journey.options
        options.insert(.unanimated)

        let previewJourney = PreviewJourney(options: options) {
            journey
        }
        .addConfiguration { presenter in
            if #available(iOS 14.0, *) {
                presenter.viewController.overrideUserInterfaceStyle = .init(
                    context.environment.colorScheme
                )
            }
        }

        navigationController.present(
            previewJourney
        )
        .onValue { _ in }

        return navigationController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

extension View {
    public func mockState<S: Store>(_ type: S.Type, getState: (_ state: S.State) -> S.State) -> Self {
        let store: S = globalPresentableStoreContainer.get()
        store.setState(getState(store.stateSignal.value))
        return self
    }
}
