import AVKit
import Apollo
import Flow
import Form
import Offer
import Presentation
import UIKit
import hCore
import hGraphQL

struct Chat {
  @Inject var client: ApolloClient
  let reloadChatCallbacker = Callbacker<Void>()
  let chatState = ChatState.shared

  private var reloadChatSignal: Signal<Void> {
    reloadChatCallbacker.providedSignal
  }
}

typealias ChatListContent = Either<Message, TypingIndicator>

enum NavigationEvent {
  case dashboard, offer, login
}

extension JourneyPresentation {
  public var hidesBackButton: Self {
    addConfiguration { presenter in
      presenter.viewController.navigationItem.hidesBackButton = true
    }
  }
}

enum ChatResult {
  case offer(ids: [String])
  case loggedIn
  case login

  var journey: some JourneyPresentation {
    GroupJourney {
      switch self {
      case let .offer(ids):
        Journey(
          Offer(
            offerIDContainer: .exact(ids: ids, shouldStore: true),
            menu: Menu(
              title: nil,
              children: [
                MenuChild.appInformation,
                MenuChild.appSettings,
                MenuChild.login,
              ]
            ),
            options: [.shouldPreserveState]
          )
        ) { offerResult in
          switch offerResult {
          case .chat:
            Journey(
              FreeTextChat(),
              style: .detented(.large),
              options: [.defaults]
            )
            .withDismissButton
          case .close:
            DismissJourney()
          case .signed:
            AppJourney.postOnboarding
          case let .menu(action):
            action.journey
          }
        }
        .hidesBackButton
      case .loggedIn:
        AppJourney.loggedIn
      case .login:
        AppJourney.login
      }
    }
  }
}

extension Chat: Presentable {
  func materialize() -> (UIViewController, Signal<ChatResult>) {
    let bag = DisposeBag()

    chatState.allowNewMessageToast = false

    bag += Disposer {
      self.chatState.allowNewMessageToast = true
    }

    let navigateCallbacker = Callbacker<NavigationEvent>()

    let chatInput = ChatInput(
      chatState: chatState,
      navigateCallbacker: navigateCallbacker
    )

    let viewController = AccessoryViewController(accessoryView: chatInput)
    viewController.navigationItem.largeTitleDisplayMode = .never

    let sectionStyle = SectionStyle(
      insets: .zero,
      rowInsets: .zero,
      itemSpacing: 0,
      minRowHeight: 10,
      background: .none,
      selectedBackground: .none,
      shadow: .none,
      header: .none,
      footer: .none
    )

    let dynamicSectionStyle = DynamicSectionStyle { _ in
      sectionStyle
    }

    let style = DynamicTableViewFormStyle(
      section: dynamicSectionStyle,
      form: DynamicFormStyle.default.restyled { (style: inout FormStyle) in
        style.insets = .zero
      }
    )

    let headerPushView = UIView()
    headerPushView.snp.makeConstraints { make in
      make.height.width.equalTo(0)
    }

    let tableKit = TableKit<EmptySection, ChatListContent>(
      table: Table(),
      style: style,
      view: nil,
      headerForSection: nil,
      footerForSection: nil
    )
    tableKit.view.estimatedRowHeight = 60
    tableKit.view.keyboardDismissMode = .interactive
    tableKit.view.transform = CGAffineTransform(scaleX: 1, y: -1)
    tableKit.view.insetsContentViewsToSafeArea = false
    bag += tableKit.delegate.heightForCell.set { tableIndex -> CGFloat in
      let item = tableKit.table[tableIndex]

      if let message = item.left {
        return message.totalHeight
      }

      if let typingIndicator = item.right {
        return typingIndicator.totalHeight
      }

      return 0
    }

    tableKit.view.contentInsetAdjustmentBehavior = .never
    if #available(iOS 13.0, *) {
      tableKit.view.automaticallyAdjustsScrollIndicatorInsets = false
    }

    // hack to fix modal dismissing when dragging up in scrollView
    if #available(iOS 13.0, *) {
      func setSheetInteractionState(_ enabled: Bool) {
        let presentationController = viewController.navigationController?.presentationController
        let key = [
          "_sheet", "Interaction",
        ]
        let sheetInteraction = presentationController?.value(forKey: key.joined()) as? NSObject
        sheetInteraction?.setValue(enabled, forKey: "enabled")
      }

      bag += tableKit.delegate.willBeginDragging.onValue { _ in
        viewController.isModalInPresentation = true
        setSheetInteractionState(false)
      }

      bag += tableKit.delegate.willEndDragging.onValue { _ in
        viewController.isModalInPresentation = false
        setSheetInteractionState(true)
      }
    }

    bag += tableKit.delegate.willDisplayCell.onValue { cell, _ in
      cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }

    bag += NotificationCenter.default
      .signal(forName: UIResponder.keyboardWillChangeFrameNotification)
      .compactMap { notification in notification.keyboardInfo }
      .animated(
        mapStyle: { (keyboardInfo) -> AnimationStyle in
          AnimationStyle(
            options: keyboardInfo.animationCurve,
            duration: keyboardInfo.animationDuration,
            delay: 0
          )
        },
        animations: { keyboardInfo in
          tableKit.view.scrollIndicatorInsets = UIEdgeInsets(
            top: keyboardInfo.height,
            left: 0,
            bottom: 0,
            right: 0
          )
          let headerView = UIView()
          headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: 0,
            height: keyboardInfo.height + 20
          )
          tableKit.view.tableHeaderView = headerView
          headerView.layoutIfNeeded()
          tableKit.view.layoutIfNeeded()
        }
      )

    bag += chatState.tableSignal.atOnce().delay(by: 0.5)
      .onValue { table in
        if tableKit.table.isEmpty {
          tableKit.set(table, animation: .fade)
        } else {
          let tableAnimation = TableAnimation(
            sectionInsert: .top,
            sectionDelete: .top,
            rowInsert: .top,
            rowDelete: .fade
          )
          tableKit.set(table, animation: tableAnimation)
        }
      }

    bag += reloadChatSignal.onValue { _ in
      self.chatState.reset()
    }

    bag += viewController.install(tableKit, options: [])

    bag += DelayedDisposer(
      Disposer {
        AskForRating().ask()
      },
      delay: 2
    )

    return (
      viewController,
      Signal { callback in

        bag += navigateCallbacker.onValue { navigationEvent in
          switch navigationEvent {
          case .offer:
            client.fetch(query: GraphQL.LastQuoteOfMemberQuery())
              .onValue { data in
                guard
                  let id = data.lastQuoteOfMember.asCompleteQuote?
                    .id
                else {
                  return
                }

                callback(.offer(ids: [id]))
              }
          case .dashboard:
            callback(.loggedIn)
          case .login:
            callback(.login)
          }
        }

        return bag
      }
    )
  }
}

extension Chat: Tabable {
  func tabBarItem() -> UITabBarItem {
    UITabBarItem(title: "Chat", image: nil, selectedImage: nil)
  }
}
