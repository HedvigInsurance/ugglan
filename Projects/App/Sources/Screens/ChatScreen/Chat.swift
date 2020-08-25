//
//  Chat.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-06.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import AVKit
import Flow
import Form
import hCore
import Presentation
import UIKit

struct Chat {
    @Inject var client: ApolloClient
    let reloadChatCallbacker = Callbacker<Void>()
    let chatState = ChatState()

    private var reloadChatSignal: Signal<Void> {
        reloadChatCallbacker.providedSignal
    }
}

typealias ChatListContent = Either<Message, TypingIndicator>

enum NavigationEvent {
    case dashboard, offer, login
}

extension Chat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let navigateCallbacker = Callbacker<NavigationEvent>()

        let chatInput = ChatInput(
            chatState: chatState,
            navigateCallbacker: navigateCallbacker
        )

        let viewController = AccessoryViewController(accessoryView: chatInput)
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 70)

        bag += navigateCallbacker.onValue { navigationEvent in
            switch navigationEvent {
            case .offer:
                viewController.present(Offer(), options: [.prefersNavigationBarHidden(true)])
            case .dashboard:
                viewController.present(LoggedIn())
            case .login:
                viewController.present(BankIDLogin(), style: .detented(.medium))
            }
        }

        Chat.didOpen()

        bag += Disposer {
            Chat.didClose()
        }

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .invisible,
            selectedBackground: .invisible,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: DynamicFormStyle.default.restyled { (style: inout FormStyle) in
            style.insets = .zero
        })

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
                let sheetInteraction = presentationController?.value(forKey: "_sheetInteraction") as? NSObject
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
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                tableKit.view.scrollIndicatorInsets = UIEdgeInsets(
                    top: keyboardInfo.height,
                    left: 0,
                    bottom: 0,
                    right: 0
                )
                let headerView = UIView()
                headerView.frame = CGRect(x: 0, y: 0, width: 0, height: keyboardInfo.height + 20)
                tableKit.view.tableHeaderView = headerView
                headerView.layoutIfNeeded()
                tableKit.view.layoutIfNeeded()
            })

        bag += chatState.tableSignal.atOnce().onValue(on: .main) { table in
            if tableKit.table.isEmpty {
                tableKit.set(table, animation: .fade)
            } else {
                let tableAnimation = TableAnimation(sectionInsert: .top, sectionDelete: .top, rowInsert: .top, rowDelete: .fade)
                tableKit.set(table, animation: tableAnimation)
            }
        }

        bag += reloadChatSignal.onValue { _ in
            self.chatState.reset()
        }

        bag += viewController.install(tableKit)

        bag += DelayedDisposer(
            Disposer {
                AskForRating().ask()
            },
            delay: 2
        )

        return (viewController, Future { _ in
            bag
        })
    }
}

extension Chat: Tabable {
    func tabBarItem() -> UITabBarItem {
        UITabBarItem(title: "Chat", image: nil, selectedImage: nil)
    }
}
