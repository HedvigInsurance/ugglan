import Combine
import Flow
import Foundation
import Presentation
import SwiftUI

@propertyWrapper
public struct PresentableStore<S: Store> {
    public var wrappedValue: S { globalPresentableStoreContainer.get() }

    public init() {}
}

public class HostingJourneyController<RootView: View>: UIHostingController<RootView> {
    var updateFrameOnViewDidLayouSubviews = true
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        /// Force set frame to make SwiftUI resize itself accordingly
        if updateFrameOnViewDidLayouSubviews {
            if let navigationController = self.navigationController,
                let presentedFrame = navigationController.presentationController?.presentedView?.frame
            {
                self.view.frame.size = presentedFrame.size
                self.view.setNeedsUpdateConstraints()
            }
        }
    }
}

public struct HostingJourney<RootView: View, Result>: JourneyPresentation {
    public typealias P = AnyPresentable<HostingJourneyController<RootView>, Result>

    public var onDismiss: (Error?) -> Void

    public var style: PresentationStyle

    public var options: PresentationOptions

    public var transform: (P.Result) -> P.Result

    public var configure: (JourneyPresenter<P>) -> Void

    public let presentable: P

    public init<S: Store, InnerJourney: JourneyPresentation>(
        _ storeType: S.Type,
        rootView: RootView,
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults, .autoPop],
        @JourneyBuilder _ content: @escaping (_ action: S.Action) -> InnerJourney
    ) where Result == Signal<S.Action> {
        self.style = style
        self.options = options
        self.configure = { _ in }

        var result: P.Result? = nil
        var previousPresenter: JourneyPresenter<InnerJourney.P>? = nil

        self.transform = { signal in
            result = signal
            return signal
        }

        configure = { presenter in
            presenter.bag += result?
                .filter(predicate: { _ in
                    let addedToWindow = presenter.viewController.view.window != nil
                    let ignoreActionWhenNotOnTop = options.contains(.ignoreActionWhenNotOnTop)
                    if ignoreActionWhenNotOnTop {
                        let isPresenting =
                            (presenter.viewController.presentedViewController
                                ?? presenter.viewController.navigationController?.presentedViewController) != nil
                        return addedToWindow && !isPresenting
                    }
                    return addedToWindow
                })
                .onValue { value in
                    let presentation = content(value)

                    if presentation.options.contains(.replaceDetail) {
                        previousPresenter?.bag.dispose()
                    }

                    let presentationWithError =
                        presentation.onError { error in
                            if let error = error as? JourneyError,
                                error == JourneyError.dismissed
                            {
                                if let vc = presenter.viewController.presentedViewController,
                                    options.contains(.dismissOnlyTopPresentedViewController)
                                {
                                    vc.dismiss(animated: true)
                                } else {
                                    presenter.dismisser(error)
                                }
                            }
                        }
                        .addConfiguration { presenter in
                            if presentation.options.contains(.replaceDetail) {
                                previousPresenter = presenter
                            }
                        }

                    let result: JourneyPresentResult<InnerJourney> = presenter.matter.present(
                        presentationWithError
                    )

                    switch result {
                    case let .presented(result):
                        presenter.bag.hold(result as AnyObject)
                    case .shouldDismiss:
                        presenter.dismisser(JourneyError.dismissed)
                    case .shouldPop:
                        presenter.dismisser(JourneyError.cancelled)
                    case .shouldContinue:
                        break
                    }
                }

            presenter.viewController.debugPresentationTitle = "\(type(of: rootView))"
        }

        self.presentable = AnyPresentable(materialize: {
            let controller = HostingJourneyController(rootView: rootView)
            if options.contains(.ignoreSizeChange) {
                controller.updateFrameOnViewDidLayouSubviews = false
            }
            controller.debugPresentationTitle = "\(RootView.self)"
            return (
                controller,
                Signal<S.Action> { callback in
                    let bag = DisposeBag()

                    let store: S = globalPresentableStoreContainer.get()

                    bag += store.actionSignal.onValue { result in
                        callback(result)
                    }

                    return bag
                }
            )
        })

        onDismiss = { _ in
            result = nil
            previousPresenter = nil
        }
    }

    public init(
        rootView: RootView,
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults, .autoPop]
    ) where Result == Disposable {
        self.style = style
        self.options = options
        self.configure = { presenter in
            presenter.viewController.debugPresentationTitle = "\(type(of: rootView))"

        }
        self.presentable = AnyPresentable(materialize: {
            let controller = HostingJourneyController(rootView: rootView)
            controller.debugPresentationTitle = "\(RootView.self)"

            return (
                controller,
                NilDisposer()
            )
        })
        onDismiss = { _ in }
        self.transform = { $0 }
    }
}

extension View {
    public var disposableHostingJourney: HostingJourney<Self, Disposable> {
        HostingJourney(rootView: self)
    }
}

extension PresentationOptions {
    public static let ignoreActionWhenNotOnTop = PresentationOptions()
    public static let dismissOnlyTopPresentedViewController = PresentationOptions()
    public static let ignoreSizeChange = PresentationOptions()
}
