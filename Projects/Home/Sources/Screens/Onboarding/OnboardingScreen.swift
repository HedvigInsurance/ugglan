import Presentation
import SwiftUI
import hCore
import hCoreUI

struct OnboardingScreen<CustomView: View>: View {
    let description: String
    let onNextClick: () -> Void
    let image: Image?
    let customView: (() -> CustomView)?
    let isNotification: Bool?

    init(
        description: String,
        onNextClick: @escaping () -> Void,
        image: Image? = nil,
        customView: (() -> CustomView)? = nil,
        isNotification: Bool? = nil
    ) {
        self.description = description
        self.onNextClick = onNextClick
        self.image = image
        self.customView = customView
        self.isNotification = isNotification
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 56) {
                    VStack(spacing: 16) {
                        HStack {
                            if let image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .fixedSize(horizontal: true, vertical: false)
                                //                                    .frame(width: 24, height: 24)
                            } else if let isNotification, isNotification {
                                Toggle("", isOn: .constant(true))
                                    .frame(width: 23)
                            }
                        }
                        .frame(height: 164)
                        .frame(maxWidth: .infinity)
                        .background {
                            Squircle.default()
                                .fill(hFillColor.opaqueThree)
                        }

                        hText(description)
                            .foregroundColor(hTextColor.secondary)
                    }

                    HStack(spacing: 4) {
                        hText("Next")
                        Image(uiImage: hCoreUIAssets.arrowForward.image)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .onTapGesture {
                        onNextClick()
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension OnboardingScreen {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen(
                description:
                    "Your digital service assistant where you can manage your insurance from the comfort of your sofa. \n\nLet us show you what you can do",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingGetHelp)
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .openOnboardingGetHelp = action {
                openGetHelpScreen
            }
        }
        .configureTitle("Welcome to the Hedvig app")
    }

    static var openGetHelpScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen<EmptyView>(
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse nec lobortis est. Maecenas fermentum, sapien at venenatis cursus, diam neque tristique nulla, ac tempor purus magna et magna.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingNotifications)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.onboardingOneTap.image)
                        .resizable()
                }()
            )
        ) { action in
            if case .openOnboardingNotifications = action {
                openNotificationsScreen
            }
        }
        .configureTitle("Get help with one tap")
    }

    static var openNotificationsScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen<HStack>(
                description: "Turn on push notifications and make sure your email and phone number is up to date.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingDocuments)
                },
                customView: {
                    let view = HStack {
                        hText("Turn on notifications")
                        Spacer()
                        Toggle(
                            isOn: .constant(true),
                            label: {
                                Text("Label")
                            }
                        )
                    }

                    return view
                },
                isNotification: true
            )
        ) { action in
            if case .openOnboardingDocuments = action {
                openDocumentsScreen
            }
        }
        .configureTitle("Stay updated")
    }

    static var openDocumentsScreen: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OnboardingScreen<EmptyView>(
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse nec lobortis est. Maecenas fermentum, sapien at venenatis cursus, diam neque tristique nulla, ac tempor purus magna et magna.",
                onNextClick: {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.openOnboardingDocuments)
                },
                image: {
                    Image(uiImage: hCoreUIAssets.toggle.image)
                }()
            )
        ) { action in
            if case .openOnboardingNotifications = action {
                openGetHelpScreen
            }
        }
        .configureTitle("Get your documents in one place")
    }
}

#Preview{
    OnboardingScreen<EmptyView>(
        description:
            "Your digital service assistant where you can manage your insurance from the comfort of your sofa. \n\nLet us show you what you can do",
        onNextClick: {},
        image: {
            Image(uiImage: hCoreUIAssets.onboardingOneTap.image)
        }(),
        isNotification: true
    )
}
