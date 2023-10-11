import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ForeverView: View {
    @PresentableStore var store: ForeverStore
    @State var scrollTo: Int = -1

    public init() {}

    public var body: some View {
        LoadingViewWithContent(ForeverStore.self, [.fetchForeverData], [.fetch]) {
            ScrollViewReader { value in
                hForm {
                    VStack(spacing: 16) {
                        HeaderView { scrollTo = 2 }.id(0)
                        DiscountCodeSectionView().id(1)
                        InvitationTable().id(2)
                    }
                }
                .onChange(of: scrollTo) { newValue in
                    if newValue != 0 {
                        withAnimation {
                            value.scrollTo(newValue, anchor: .top)
                        }
                        scrollTo = 0
                    }
                }
            }
            .onAppear {
                store.send(.fetch)
            }
            .navigationBarItems(
                trailing:
                    PresentableStoreLens(
                        ForeverStore.self,
                        getter: { state in
                            state.foreverData?.monthlyDiscountPerReferral
                        }
                    ) { discountAmount in
                        Button(action: {
                            if let discountAmount {
                                store.send(.showInfoSheet(discount: discountAmount.formattedAmount))
                            }
                        }) {
                            Image(uiImage: hCoreUIAssets.infoIcon.image)
                                .foregroundColor(hTextColor.primary)
                        }
                    }
            )
        }
    }
}

extension ForeverView {
    public static func journey() -> some JourneyPresentation {
        HostingJourney(
            ForeverStore.self,
            rootView: ForeverView()
        ) { action in
            if case .showChangeCodeDetail = action {
                ChangeCodeView.journey
            } else if case let .showShareSheetOnly(code, discount) = action {
                shareSheetJourney(code: code, discount: discount)
            } else if case let .showInfoSheet(discount) = action {
                infoSheetJourney(potentialDiscount: discount)
            }
        }
        .configureTitle(L10n.ReferralsInfoSheet.headline)
        .configureForeverTabBarItem
        .configureTabBarBorder
    }

    static func infoSheetJourney(potentialDiscount: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: InfoView(
                title: L10n.ReferralsInfoSheet.headline,
                description: L10n.ReferralsInfoSheet.body(potentialDiscount),
                onDismiss: {
                    let store: ForeverStore = globalPresentableStoreContainer.get()
                    store.send(.closeInfoSheet)
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        )
        .onAction(ForeverStore.self) { action in
            if case .closeInfoSheet = action {
                DismissJourney()
            }
        }
    }

    static func shareSheetJourney(code: String, discount: String) -> some JourneyPresentation {
        let url =
            "\(hGraphQL.Environment.current.webBaseURL)/\(hCore.Localization.Locale.currentLocale.webPath)/forever/\(code)"
        let message = L10n.referralSmsMessage(discount, url)
        return HostingJourney(
            rootView: ActivityViewController(activityItems: [
                message
            ]),
            style: .activityView
        )
    }
}

struct ForeverView_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return ForeverView()
            .onAppear {
                let foreverData = ForeverData.mock()
                store.send(.setForeverData(data: foreverData))
            }
    }
}
