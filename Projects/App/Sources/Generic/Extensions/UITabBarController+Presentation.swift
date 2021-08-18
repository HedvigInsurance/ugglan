import Flow
import Foundation
import Presentation
import UIKit
import hCore

extension UITabBarController {
  private func materializeTab<P: Presentable & Tabable, Matter: UIViewController>(
    _ presentation: Presentation<P>
  ) -> (UIViewController, Disposable) where P.Matter == Matter, P.Result == Disposable {
    let bag = DisposeBag()

    let materialized = presentation.presentable.materialize()

    bag += presentation.transform(materialized.1)

    let viewController = materialized.0.embededInNavigationController(presentation.options)

    presentation.configure(materialized.0, bag)

    if let navigationController = viewController as? UINavigationController {
      navigationController.tabBarItem = presentation.presentable.tabBarItem()
    } else if let splitController = viewController as? UISplitViewController {
      splitController.tabBarItem = presentation.presentable.tabBarItem()
    }

    if let presentableIdentifier = (presentation.presentable as? PresentableIdentifierExpressible)?
      .presentableIdentifier
    {
      viewController.debugPresentationTitle = presentableIdentifier.value
    } else {
      let title = "\(type(of: presentation.presentable))"
      if !title.hasPrefix("AnyPresentable<") { viewController.debugPresentationTitle = title }
    }

    return (viewController, bag)
  }

  // swiftlint:disable identifier_name
  func presentTabs<
    A: Presentable & Tabable,
    AMatter: UIViewController,
    B: Presentable & Tabable,
    BMatter: UIViewController,
    C: Presentable & Tabable,
    CMatter: UIViewController,
    D: Presentable & Tabable,
    DMatter: UIViewController,
    E: Presentable & Tabable,
    EMatter: UIViewController
  >(
    _ a: Presentation<A>,
    _ b: Presentation<B>,
    _ c: Presentation<C>,
    _ d: Presentation<D>,
    _ e: Presentation<E>
  ) -> Disposable
  where
    A.Matter == AMatter, A.Result == Disposable, B.Matter == BMatter, B.Result == Disposable,
    C.Matter == CMatter, C.Result == Disposable, D.Matter == DMatter, D.Result == Disposable,
    E.Matter == EMatter, E.Result == Disposable
  {
    let bag = DisposeBag()

    let tabA = materializeTab(a)
    let tabB = materializeTab(b)
    let tabC = materializeTab(c)
    let tabD = materializeTab(d)
    let tabE = materializeTab(e)

    bag += tabA.1
    bag += tabB.1
    bag += tabC.1
    bag += tabD.1
    bag += tabE.1

    viewControllers = [tabA.0, tabB.0, tabC.0, tabD.0, tabE.0]

    return bag
  }

  func presentTabs<
    A: Presentable & Tabable,
    AMatter: UIViewController,
    B: Presentable & Tabable,
    BMatter: UIViewController,
    C: Presentable & Tabable,
    CMatter: UIViewController,
    D: Presentable & Tabable,
    DMatter: UIViewController
  >(_ a: Presentation<A>, _ b: Presentation<B>, _ c: Presentation<C>, _ d: Presentation<D>) -> Disposable
  where
    A.Matter == AMatter, A.Result == Disposable, B.Matter == BMatter, B.Result == Disposable,
    C.Matter == CMatter, C.Result == Disposable, D.Matter == DMatter, D.Result == Disposable
  {
    let bag = DisposeBag()

    let tabA = materializeTab(a)
    let tabB = materializeTab(b)
    let tabC = materializeTab(c)
    let tabD = materializeTab(d)

    bag += tabA.1
    bag += tabB.1
    bag += tabC.1
    bag += tabD.1

    viewControllers = [tabA.0, tabB.0, tabC.0, tabD.0]

    return bag
  }

  func presentTabs<
    A: Presentable & Tabable,
    AMatter: UIViewController,
    B: Presentable & Tabable,
    BMatter: UIViewController,
    C: Presentable & Tabable,
    CMatter: UIViewController
  >(_ a: Presentation<A>, _ b: Presentation<B>, _ c: Presentation<C>) -> Disposable
  where
    A.Matter == AMatter, A.Result == Disposable, B.Matter == BMatter, B.Result == Disposable,
    C.Matter == CMatter, C.Result == Disposable
  {
    let bag = DisposeBag()

    let tabA = materializeTab(a)
    let tabB = materializeTab(b)
    let tabC = materializeTab(c)

    bag += tabA.1
    bag += tabB.1
    bag += tabC.1

    viewControllers = [tabA.0, tabB.0, tabC.0]

    return bag
  }

  func presentTabs<
    A: Presentable & Tabable,
    AMatter: UIViewController,
    B: Presentable & Tabable,
    BMatter: UIViewController
  >(_ a: Presentation<A>, _ b: Presentation<B>) -> Disposable
  where A.Matter == AMatter, A.Result == Disposable, B.Matter == BMatter, B.Result == Disposable {
    let bag = DisposeBag()

    let tabA = materializeTab(a)
    let tabB = materializeTab(b)

    bag += tabA.1
    bag += tabB.1

    viewControllers = [tabA.0, tabB.0]

    return bag
  }

  func presentTabs<A: Presentable & Tabable, AMatter: UIViewController>(_ a: Presentation<A>) -> Disposable
  where A.Matter == AMatter, A.Result == Disposable {
    let bag = DisposeBag()

    let tabA = materializeTab(a)
    bag += tabA.1

    viewControllers = [tabA.0]

    return bag
  }

  // swiftlint:enable identifier_name
}
