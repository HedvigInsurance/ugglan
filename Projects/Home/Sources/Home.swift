import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct Home {
  public static var openClaimsHandler: (_ viewController: UIViewController) -> Void = { _ in }
  public static var openMovingFlowHandler: (_ viewController: UIViewController) -> Void = { _ in }
  public static var openFreeTextChatHandler: (_ viewController: UIViewController) -> Void = { _ in }
  public static var openConnectPaymentHandler: (_ viewController: UIViewController) -> Void = { _ in }

  @Inject var client: ApolloClient

  public init(
    sections: [HomeSection]
  ) {
    self.sections = sections
  }

  public let sections: [HomeSection]
}

extension Future {
  func wait(until signal: ReadSignal<Bool>) -> Future<Value> {
    Future<Value> { completion in
      let bag = DisposeBag()

      self.onValue { value in
        bag += signal.atOnce().filter(predicate: { $0 })
          .onValue { _ in
            completion(.success(value))
          }
      }
      .onError { error in
        completion(.failure(error))
      }

      return bag
    }
  }
}

enum HomeState {
  case terminated
  case future
  case active
}

extension Home: Presentable {
  public func materialize() -> (UIViewController, Disposable) {
    let viewController = UIViewController()
    viewController.title = L10n.HomeTab.title
    viewController.installChatButton(allowsChatHint: true)

    if #available(iOS 13.0, *) {
      let scrollEdgeAppearance = UINavigationBarAppearance()
      DefaultStyling.applyCommonNavigationBarStyling(scrollEdgeAppearance)
      scrollEdgeAppearance.configureWithTransparentBackground()
      scrollEdgeAppearance.largeTitleTextAttributes = scrollEdgeAppearance.largeTitleTextAttributes
        .merging(
          [
            NSAttributedString.Key.foregroundColor: UIColor.clear
          ],
          uniquingKeysWith: takeRight
        )

      viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
    }

    let bag = DisposeBag()

    let form = FormView()
    bag += viewController.install(form) { scrollView in
      let refreshControl = UIRefreshControl()
      scrollView.refreshControl = refreshControl
      bag += self.client.refetchOnRefresh(query: GraphQL.HomeQuery(), refreshControl: refreshControl)

      bag += scrollView.performEntryAnimation(
        contentView: form,
        onLoad: self.client
          .fetch(query: GraphQL.HomeQuery())
          .wait(until: scrollView.safeToPerformEntryAnimationSignal)
          .delay(by: 0.1)
      ) { error in
        print(error)
      }
    }

    bag += form.append(ImportantMessagesSection())

    let rowInsets = UIEdgeInsets(
      top: 0,
      left: 25,
      bottom: 0,
      right: 25
    )

    let titleSection = form.appendSection()
    let titleRow = RowView()
    titleRow.isLayoutMarginsRelativeArrangement = true
    titleRow.layoutMargins = rowInsets
    titleSection.append(titleRow)

    func buildSections(functionBag: DisposeBag, state: HomeState) {
      switch state {
      case .active:
        functionBag += titleRow.append(ActiveSection())
      case .future:
        functionBag += titleRow.append(FutureSection())
      case .terminated:
        functionBag += titleRow.append(TerminatedSection())
      }

      sections.forEach { homeSection in
        switch homeSection.style {
        case .horizontal:
          break
        case .vertical:
          guard state == .active else { return }
          let section = HomeVerticalSection(section: homeSection)
          functionBag += form.append(section)
        case .header:
          break
        }

        form.appendSpacing(.custom(30))
      }
    }

    bag += NotificationCenter.default.signal(forName: UIApplication.didBecomeActiveNotification)
      .mapLatestToFuture { _ in
        self.client.fetch(query: GraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)
      }
      .nil()

    bag +=
      client
      .watch(query: GraphQL.HomeQuery())
      .map { data in
        data.homeState
      }
      .onValueDisposePrevious { homeState in
        let innerBag = DisposeBag()

        buildSections(functionBag: innerBag, state: homeState)

        return innerBag
      }

    return (viewController, bag)
  }
}

extension Home: Tabable {
  public func tabBarItem() -> UITabBarItem {
    UITabBarItem(
      title: L10n.HomeTab.title,
      image: Asset.tab.image,
      selectedImage: Asset.tabSelected.image
    )
  }
}

extension GraphQL.HomeQuery.Data {
  fileprivate var homeState: HomeState {
    if isTerminated {
      return .terminated
    } else if isFuture {
      return .future
    } else {
      return .active
    }
  }

  private var isTerminated: Bool {
    contracts.allSatisfy({ (contract) -> Bool in
      contract.status.asActiveInFutureStatus != nil || contract.status.asTerminatedStatus != nil
        || contract.status.asTerminatedTodayStatus != nil
    })
  }

  private var isFuture: Bool {
    contracts.allSatisfy { (contract) -> Bool in
      contract.status.asActiveInFutureStatus != nil || contract.status.asPendingStatus != nil
    }
  }
}
