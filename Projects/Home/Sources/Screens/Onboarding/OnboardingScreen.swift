import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct OnboardingScreen: View {
    let description: String
    let onNextClick: () -> Void
    let image: Image?
    let isNotification: Bool?
    let isFinalScreen: Bool
    let addBackgroundImage: Bool

    @State var notificationText = "Turn on notifications"

    var cancellables = Set<AnyCancellable>()

    @StateObject var vm = OnboardingViewModel()

    @Binding var currentIndex: Int
    let totalAmountOfPages = 5

    init(
        description: String,
        onNextClick: @escaping () -> Void,
        image: Image? = nil,
        isNotification: Bool? = nil,
        currentIndex: Binding<Int>,
        isFinalScreen: Bool? = false,
        addBackgroundImage: Bool? = false
    ) {
        self.description = description
        self.onNextClick = onNextClick
        self.image = image
        self.isNotification = isNotification
        self._currentIndex = currentIndex
        self.addBackgroundImage = addBackgroundImage ?? false
        self.isFinalScreen = isFinalScreen ?? false
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 24) {
                    HStack {
                        if let image {
                            if !addBackgroundImage {
                                image
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                ZStack(alignment: .center) {
                                    Image(uiImage: hCoreUIAssets.onboardingBackground.image)
                                        .resizable()
                                        .scaledToFit()

                                    image
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        } else if let isNotification, isNotification {
                            ZStack {
                                Image(uiImage: hCoreUIAssets.onboardingBackgroundSmall.image)
                                    .resizable()
                                    .scaledToFit()

                                Toggle("", isOn: .constant(true))
                                    .frame(width: 23)
                            }
                        }
                    }
                    .clipShape(Squircle.default())
                    .hShadow()

                    VStack(alignment: .leading, spacing: 72) {
                        hText(description)
                            .foregroundColor(hTextColor.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if isNotification ?? false {
                            HStack {
                                hText(notificationText)
                                    .fixedSize()
                                    .foregroundColor(hTextColor.secondary)
                                Spacer()

                                Toggle(
                                    isOn: $vm.pushNotificationsIsOn,
                                    label: {
                                    }
                                )
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hDisableScroll
        .hFormAttachToBottom {
            hSection {
                HStack {
                    hPagerDotsBinded(currentIndex: $currentIndex, totalCount: totalAmountOfPages)
                        .padding(.leading, 138)

                    Spacer()

                    hButton.SmallButton(type: .primary) {
                        onNextClick()
                    } content: {
                        hText(isFinalScreen ? "Done" : "Next")
                    }
                    .fixedSize()
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 18)
        }
        .onUpdate(of: vm.pushNotificationsIsOn) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    notificationText = "Notifications turned on"
                }
            }
        }
    }
}

public class OnboardingViewModel: ObservableObject {
    @Published var pushNotificationsIsOn = false
    var cancellables = Set<AnyCancellable>()

    init() {
        $pushNotificationsIsOn
            .receive(on: RunLoop.main)
            .sink { _ in
                let store: HomeStore = globalPresentableStoreContainer.get()

                /* TODO: push notifications already enabled */
                //                if profileStore.state.pushNotificationCurrentStatus() != .authorized {
                //                    pushNotificationsIsOn = true

                if self.pushNotificationsIsOn {
                    //                    // enable push notifications
                    store.send(.registerForPushNotifications)
                }
            }
            .store(in: &cancellables)
    }
}

extension OnboardingScreen {
    public static var start: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Your digital insurance assistant.\nHit next to explore what you can do.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingInsurance)
                },
                image: { Image(uiImage: hCoreUIAssets.welcomeToHedvig.image) }(),
                currentIndex: .constant(0)
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .openOnboardingInsurance = action {
                openInsuranceScreen
            }
        }
        .configureTitle("Welcome to the Hedvig-app")
        .addDismissOnboardingFlow
    }

    static var openInsuranceScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Your digital insurance assistant.\nHit next to explore what you can do.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingDocuments)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingInsurance.image)
                }(),
                currentIndex: .constant(0)
            )
        ) { action in
            if case .openOnboardingDocuments = action {
                openDocumentsScreen
            }
        }
        .configureTitle("Edit, move or buy more insurance")
        .addDismissOnboardingFlow
    }

    static var openDocumentsScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "See your insurance certificate or generate travel certificates.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingPayments)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingDocument.image)
                }(),
                currentIndex: .constant(1),
                addBackgroundImage: true
            )
        ) { action in
            if case .openOnboardingPayments = action {
                openPaymentsScreen
            }
        }
        .configureTitle("Your documents are ready")
        .addDismissOnboardingFlow
    }

    static var openPaymentsScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "See your history, next charge or change bank. All with a few taps.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingMakeClaim)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingPayments.image)
                }(),
                currentIndex: .constant(1)
            )
        ) { action in
            if case .openOnboardingMakeClaim = action {
                openMakeClaimsScreen
            }
        }
        .configureTitle("Full control of your payments")
        .addDismissOnboardingFlow
    }

    static var openMakeClaimsScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Directly from the home screen, without any paperwork.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingFollowClaim)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingMakeClaim.image)
                }(),
                currentIndex: .constant(1),
                addBackgroundImage: true
            )
        ) { action in
            if case .openOnboardingFollowClaim = action {
                openFollowClaimsScreen
            }
        }
        .configureTitle("Make a claim from the home screen")
        .addDismissOnboardingFlow
    }

    static var openFollowClaimsScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Chat or add documents right from the claims card on your home screen.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingGetHelp)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingClaimsCard.image)
                }(),
                currentIndex: .constant(2)
            )
        ) { action in
            if case .openOnboardingGetHelp = action {
                openGetHelpScreen
            }
        }
        .configureTitle("Follow and update your claim")
        .addDismissOnboardingFlow
    }

    static var openGetHelpScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Chat is our fastest way to get help. You can also reach us over email and phone.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingNotifications)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingNavigationElements.image)
                }(),
                currentIndex: .constant(2)
            )
        ) { action in
            if case .openOnboardingNotifications = action {
                openNotificationsScreen
            }
        }
        .configureTitle("Get help, the way you like")
        .addDismissOnboardingFlow
    }

    static var openNotificationsScreen: some JourneyPresentation {
        return HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description: "Don’t forget app messages or important updates of your insurances.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingContact)
                },
                isNotification: true,
                currentIndex: .constant(2)
            )
        ) { action in
            if case .openOnboardingContact = action {
                openContactScreen
            }
        }
        .configureTitle("Turn on notifications")
        .addDismissOnboardingFlow
    }

    static var openContactScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Got a new phone number or email address. Update it in profile tab.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingForever)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingContact.image)
                }(),
                currentIndex: .constant(3)
            )
        ) { action in
            if case .openOnboardingForever = action {
                openForeverScreen
            }
        }
        .configureTitle("Keep your contact details up to date")
        .addDismissOnboardingFlow
    }

    static var openForeverScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Invite friends and lower your and their monthly premiums.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingFinish)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingForever.image)
                }(),
                currentIndex: .constant(3)
            )
        ) { action in
            if case .openOnboardingFinish = action {
                openFinishScreen
            }
        }
        .configureTitle("Hedvig Forever")
        .addDismissOnboardingFlow
    }

    static var openFinishScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Continue to explore the app and finish your profile.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.dismissOnboardingFlow)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingFinal.image)
                }(),
                currentIndex: .constant(4),
                isFinalScreen: true
            )
        ) { action in
            if case .dismissOnboardingFlow = action {
                DismissJourney()
            }
        }
        .configureTitle("That’s a wrap")
        .addDismissOnboardingFlow
    }
}

extension JourneyPresentation {
    var addDismissOnboardingFlow: some JourneyPresentation {
        self.withJourneyDismissButtonWithConfirmation(
            withTitle: L10n.General.areYouSure,
            andBody:
                "If you proceed you will exit the onboarding. If you need any further help you can find answer to most questions in the help center.",
            andCancelText: L10n.General.no,
            andConfirmText: L10n.General.yes
        )
    }
}

#Preview{
    OnboardingScreen(
        description:
            "Your digital service assistant where you can manage your insurance from the comfort of your sofa. \n\nLet us show you what you can do",
        onNextClick: {},
        image: {
            Image(uiImage: hCoreUIAssets.onboardingOneTap.image)
        }(),
        //        isNotification: true,
        currentIndex: .constant(0)
    )
}
