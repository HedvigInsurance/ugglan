import Flow
import Foundation
import Presentation
import UIKit

extension UIViewController: UIViewControllerPreviewingDelegate {
  private static var _previewingContextDelegates = [
    UIView: Delegate<Void, AnyPresentable<UIViewController, Disposable>>
  ]()

  private static var _didCommitPreviewingCallbackers = [UIView: Callbacker<Void>]()

  public func previewingContext(
    _ previewingContext: UIViewControllerPreviewing,
    viewControllerForLocation _: CGPoint
  ) -> UIViewController? {
    let presentable = UIViewController._previewingContextDelegates[previewingContext.sourceView]?.call()

    if let presentable = presentable {
      let (viewController, _) = presentable.materialize()
      return viewController
    }

    return nil
  }

  public func previewingContext(
    _ previewingContext: UIViewControllerPreviewing,
    commit viewController: UIViewController
  ) {
    UIViewController._didCommitPreviewingCallbackers[previewingContext.sourceView]?.callAll()
    navigationController?.pushViewController(viewController, animated: true)
    viewControllerWasPresented(viewController)
  }

  func registerForPreviewing<P: Presentable, FutureResult: Any>(
    sourceView: UIView,
    presentable: P,
    options: PresentationOptions
  ) -> Disposable where P.Matter == UIViewController, P.Result == Future<FutureResult> {
    registerForPreviewing(with: self, sourceView: sourceView)

    let bag = DisposeBag()

    UIViewController._previewingContextDelegates[sourceView] = Delegate()
    UIViewController._didCommitPreviewingCallbackers[sourceView] = Callbacker()

    bag += UIViewController._previewingContextDelegates[sourceView]!
      .set { () -> AnyPresentable<UIViewController, Disposable> in
        AnyPresentable {
          let (viewController, future) = presentable.materialize()

          let autoPopFuture = future.onValue { _ in
            viewController.navigationController?.popViewController(animated: true)
          }

          viewController.setLargeTitleDisplayMode(options)

          let innerBag = bag.innerBag()

          // dispose preview if it's left without a window for 500ms
          innerBag += viewController.view.windowSignal.debounce(0.5)
            .filter(predicate: { $0 == nil })
            .onValue { _ in innerBag.dispose()
              autoPopFuture.cancel()
            }

          // cancel preview disposal by disposing innerBag when a commit happens
          innerBag += UIViewController._didCommitPreviewingCallbackers[sourceView]?
            .signal().onValue { _ in innerBag.dispose() }

          bag += future.disposable
          return (viewController, future.disposable)
        }
      }

    return Disposer {
      bag.dispose()
      UIViewController._previewingContextDelegates[sourceView] = nil
      UIViewController._didCommitPreviewingCallbackers[sourceView] = nil
    }
  }

  func registerForPreviewing<P: Previewable>(sourceView: UIView, previewable: P) -> Disposable
  where P.PreviewMatter.Matter == UIViewController, P.PreviewMatter.Result == Disposable {
    let (presentable, options) = previewable.preview()
    return registerForPreviewing(sourceView: sourceView, presentable: presentable, options: options)
  }

  func registerForPreviewing<P: Previewable, FutureResult: Any>(sourceView: UIView, previewable: P) -> Disposable
  where P.PreviewMatter.Matter == UIViewController, P.PreviewMatter.Result == Future<FutureResult> {
    let (presentable, options) = previewable.preview()
    return registerForPreviewing(sourceView: sourceView, presentable: presentable, options: options)
  }

  func registerForPreviewing<P: Presentable>(
    sourceView: UIView,
    presentable: P,
    options: PresentationOptions
  ) -> Disposable where P.Matter == UIViewController, P.Result == Disposable {
    registerForPreviewing(with: self, sourceView: sourceView)

    let bag = DisposeBag()

    UIViewController._previewingContextDelegates[sourceView] = Delegate()
    UIViewController._didCommitPreviewingCallbackers[sourceView] = Callbacker()

    bag += UIViewController._previewingContextDelegates[sourceView]!
      .set { () -> AnyPresentable<UIViewController, Disposable> in
        AnyPresentable {
          let (viewController, disposable) = presentable.materialize()
          let innerBag = bag.innerBag()

          viewController.setLargeTitleDisplayMode(options)

          // dispose preview if it's left without a window for 500ms
          innerBag += viewController.view.windowSignal.debounce(0.5)
            .filter(predicate: { $0 == nil }).onValue { _ in disposable.dispose() }

          // cancel preview disposal by disposing innerBag when a commit happens
          innerBag += UIViewController._didCommitPreviewingCallbackers[sourceView]?
            .signal().onValue { _ in innerBag.dispose() }

          bag += disposable
          return (viewController, disposable)
        }
      }

    return Disposer {
      bag.dispose()
      UIViewController._previewingContextDelegates[sourceView] = nil
      UIViewController._didCommitPreviewingCallbackers[sourceView] = nil
    }
  }
}
