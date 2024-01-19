import Apollo
import Chat
import Flow
import Foundation
import Presentation
import Profile
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    @JourneyBuilder
    static func freeTextChat(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        if Dependencies.featureFlags().isChatDisabled {
            AppJourney.disableChatScreen(style: style)
        } else {
            ChatJourney.start(
                style: style,
                resultJourney: { result in
                    if case .notifications = result {
                        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                        let status = profileStore.state.pushNotificationCurrentStatus()
                        if case .notDetermined = status {
                            HostingJourney(
                                UgglanStore.self,
                                rootView: AskForPushnotifications(
                                    text: L10n.chatActivateNotificationsBody,
                                    onActionExecuted: {
                                        let store: UgglanStore = globalPresentableStoreContainer.get()
                                        store.send(.dismissScreen)
                                    }
                                ),
                                style: .detented(.large)
                            ) { action in
                                PopJourney()
                            }
                        }
                    }
                }
            )
        }
    }

    @JourneyBuilder
    static func claimsChat(style: PresentationStyle = .default) -> some JourneyPresentation {
        if Dependencies.featureFlags().isChatDisabled {
            AppJourney.disableChatScreen(style: style)
        } else {
            ChatJourney.start(
                style: style,
                resultJourney: { result in
                    if case .notifications = result {
                        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                        let status = profileStore.state.pushNotificationCurrentStatus()
                        if case .notDetermined = status {
                            HostingJourney(
                                UgglanStore.self,
                                rootView: AskForPushnotifications(
                                    text: L10n.chatActivateNotificationsBody,
                                    onActionExecuted: {
                                        let store: UgglanStore = globalPresentableStoreContainer.get()
                                        store.send(.dismissScreen)
                                    }
                                ),
                                style: .detented(.large)
                            ) { action in
                                PopJourney()
                            }
                        }
                    }
                }
            )
        }
    }

    static func disableChatScreen(style: PresentationStyle = .default) -> some JourneyPresentation {
        return HostingJourney(
            rootView: GenericErrorView(
                title: nil,
                description: L10n.chatDisabledMessage,
                icon: .triangle,
                buttons: .init(
                    actionButton:
                        .init(
                            buttonTitle: L10n.generalCloseButton,
                            buttonAction: {
                                let store: UgglanStore = globalPresentableStoreContainer.get()
                                store.send(.closeChat)
                            }
                        ),
                    dismissButton: nil
                )
            )
            .hWithoutTitle,
            style: style,
            options: [.embedInNavigationController, .preffersLargerNavigationBar]
        )
        .onAction(UgglanStore.self) { action in
            if case .closeChat = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.chatTitle)
    }
}
