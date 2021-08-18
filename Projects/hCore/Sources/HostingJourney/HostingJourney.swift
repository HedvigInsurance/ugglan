import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit

@propertyWrapper
public struct PresentableStore<S: Store> {
    public var wrappedValue: S { globalPresentableStoreContainer.get() }

    public init() {}
}

public struct HostingJourney<RootView: View, Result>: JourneyPresentation {
    public typealias P = AnyPresentable<UIViewController, Result>

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
                                presenter.dismisser(error)
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
        }

        self.presentable = AnyPresentable(materialize: {
            let controller = ViewHostingController(rootView: rootView)
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
        self.configure = { _ in }
        self.presentable = AnyPresentable(materialize: {
            let controller = ViewHostingController(rootView: rootView)
            return (
                controller,
                NilDisposer()
            )
        })
        onDismiss = { _ in }
        self.transform = { $0 }
    }
}

private struct EnvironmentPresentableViewUpperScrollView: EnvironmentKey {
    static let defaultValue: UIScrollView? = nil
}

extension EnvironmentValues {
    public var presentableViewUpperScrollView: UIScrollView? {
        get { self[EnvironmentPresentableViewUpperScrollView.self] }
        set { self[EnvironmentPresentableViewUpperScrollView.self] = newValue }
    }
}

public class ViewHostingController<RootView: View>: UIViewController {
    let hostingController: UIHostingController<AnyView>
    let scrollView = UIScrollView()

    init(
        rootView: RootView
    ) {
        self.hostingController = UIHostingController(
            rootView: AnyView(
                rootView
                    .environment(\.presentableViewUpperScrollView, scrollView)
            )
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.backgroundColor = .white
        scrollView.isScrollEnabled = true

        self.addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
