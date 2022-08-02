import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct Slice: Shape {
    var startSlices: CGFloat = 0
    var percentage: CGFloat
    var percentagePerSlice: CGFloat
    var slices: CGFloat

    func path(in rect: CGRect) -> Path {
        return Path { path in
            let width: CGFloat = min(rect.size.width, rect.size.height)
            let height = width

            let center = CGPoint(x: width * 0.5, y: height * 0.5)

            path.move(to: center)

            path.addArc(
                center: center,
                radius: width * 0.5,
                startAngle: Angle(degrees: -90.0) + Angle(degrees: percentagePerSlice * startSlices * 360),
                endAngle: Angle(degrees: -90.0)
                    + Angle(
                        degrees: 360 * percentagePerSlice
                            * (max((slices - startSlices) * percentage, 0.0001) + startSlices)
                    ),
                clockwise: false
            )
        }
    }

    var animatableData: Double {
        get { return percentage }
        set { percentage = newValue }
    }
}

public struct PieChartView: View {
    @State var state: PieChartState
    //@State var percentagePerSlice: CGFloat
    //@State var slices: CGFloat
    @State var newPrice: String

    @State private var percentage: CGFloat = .zero
    @State private var nextSlicePercentage: CGFloat = .zero
    @State private var showNewAmount: Bool = false

    var animation: Animation {
        Animation.spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1).delay(1)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(Color(red: 1, green: 0.59, blue: 0.31, opacity: 1))
                if !state.percentagePerSlice.isNaN && state.percentagePerSlice != 0 {
                    Slice(
                        startSlices: state.slices,
                        percentage: nextSlicePercentage,
                        percentagePerSlice: state.percentagePerSlice,
                        slices: state.slices + 1
                    )
                    .fill(.white.opacity(0.5))
                    .onAppear {
                        withAnimation(self.animation.delay(state.slices == 0 ? 0 : 1.2).repeatForever()) {
                            self.nextSlicePercentage = 1.0
                        }
                    }
                    Slice(percentage: percentage, percentagePerSlice: state.percentagePerSlice, slices: state.slices)
                        .fill(.white)
                        .onAppear {
                            withAnimation(self.animation) {
                                self.percentage = 1.0
                            }
                        }
                }

                let radAngle = Angle(degrees: -(360.0 * state.slices * state.percentagePerSlice - 90.0)).radians
                // Using cosine to make sure the label is positioned nicely around the whole circle
                let offset = abs(cos(radAngle)) * 0.16 + 1.1
                VStack {
                    if state.slices != 0 && !state.slices.isNaN && showNewAmount {
                        hText(newPrice, style: .caption2)
                            .foregroundColor(hLabelColor.tertiary)
                            .transition(.opacity)
                    }
                }
                .position(
                    x: geometry.size.width * 0.5 * CGFloat(1.0 + offset * cos(radAngle)),
                    y: geometry.size.height * 0.5 * CGFloat(1.0 - offset * sin(radAngle))
                )
                .animation(self.animation.delay(0.2))
                .onAppear {
                    self.showNewAmount.toggle()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

public struct ForeverView: View {
    @PresentableStore var store: ForeverStore

    public var body: some View {
        hForm(gradientType: .forever) {
            HeaderView().slideUpAppearAnimation()
            DiscountCodeSectionView().slideUpAppearAnimation()
            InvitationTable().slideUpAppearAnimation()
        }
        .hFormAttachToBottom {
            VStack {
                Divider().background(Color(UIColor.brand(.primaryBorderColor))).padding(0).edgesIgnoringSafeArea(.all)
                PresentableStoreLens(
                    ForeverStore.self,
                    getter: { state in
                        state.foreverData?.discountCode
                    }
                ) { code in
                    if let code = code {
                        hButton.LargeButtonFilled {
                            store.send(.showShareSheet(code: code))
                        } content: {
                            hText(L10n.ReferralsEmpty.shareCodeButton)
                        }
                        .padding(.horizontal).padding(.vertical, 6)
                    }
                }
            }
            .background(Color(DefaultStyling.tabBarBackgroundColor).edgesIgnoringSafeArea(.all))
        }
        .navigationBarItems(
            trailing:
                PresentableStoreLens(
                    ForeverStore.self,
                    getter: { state in
                        state.foreverData?.potentialDiscountAmount
                    }
                ) { discountAmount in
                    if let discountAmount = discountAmount {
                        Button(action: {
                            store.send(.showInfoSheet(discount: discountAmount.formattedAmount))
                        }) {
                            Image(uiImage: hCoreUIAssets.infoLarge.image).foregroundColor(hLabelColor.primary)
                        }
                    }
                }
        )
    }
}

extension ForeverView {
    public static func journey() -> some JourneyPresentation {
        HostingJourney(
            ForeverStore.self,
            rootView: ForeverView(),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always),
            ]
        ) { action in
            if case .showTemporaryCampaignDetail = action {
                TemporaryCampaignDetail().journey
            } else if case .showChangeCodeDetail = action {
                Journey(
                    ChangeCode(service: ForeverServiceGraphQL()),
                    style: .modally()
                )
                .onDismiss {
                    let store: ForeverStore = globalPresentableStoreContainer.get()
                    store.send(.fetch)
                }
            } else if case let .showShareSheet(code) = action {
                HostingJourney(
                    rootView: ActivityViewController(activityItems: [
                        URL(
                            string: L10n.referralsLink(
                                code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            )
                        ) ?? ""
                    ]),
                    style: .activityView
                )
            } else if case let .showInfoSheet(discount) = action {
                infoSheetJourney(potentialDiscount: discount)
            }
        }
        .configureTitle(L10n.referralsScreenTitle)
        .configureForeverTabBarItem
        .addConfiguration { presenter in
            presenter.bag += presenter.viewController.view.didMoveToWindowSignal.onValue({ _ in
                if let tabBarController = presenter.viewController.tabBarController {
                    tabBarController.tabBar.shadowImage = UIColor.clear.asImage()
                }
            })

            presenter.bag += presenter.viewController.view.didMoveFromWindowSignal.onValue({ _ in
                if let tabBarController = presenter.viewController.tabBarController {
                    tabBarController.tabBar.shadowImage = UIColor.brand(.primaryBorderColor).asImage()
                }
            })

        }
    }

    static func infoSheetJourney(potentialDiscount: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: InfoAndTermsView(potentialDiscount: potentialDiscount),
            style: .modally()
        )
        .onAction(ForeverStore.self) { action in
            if case .closeInfoSheet = action {
                DismissJourney()
            }
        }
    }
}

public struct Forever {
    let service: ForeverService

    public init(service: ForeverService) { self.service = service }
}

extension Forever: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.referralsScreenTitle
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.edgesForExtendedLayout = [.top, .left, .right]
        let bag = DisposeBag()

        let infoBarButton = UIBarButtonItem(
            image: hCoreUIAssets.infoLarge.image,
            style: .plain,
            target: nil,
            action: nil
        )

        bag += infoBarButton.onValue {
            viewController.present(
                InfoAndTerms(
                    potentialDiscountAmountSignal: self.service.dataSignal.map {
                        $0?.potentialDiscountAmount
                    }
                ),
                style: .detented(.large)
            )
        }

        viewController.navigationItem.rightBarButtonItem = infoBarButton

        let tableKit = TableKit<String, InvitationRow>(style: .brandInset, holdIn: bag)
        bag += tableKit.delegate.heightForCell.set { index -> CGFloat in tableKit.table[index].cellHeight }

        bag += NotificationCenter.default.signal(forName: .costDidUpdate).onValue { _ in service.refetch() }

        let refreshControl = UIRefreshControl()

        bag += refreshControl.onValue {
            refreshControl.endRefreshing()
            self.service.refetch()
        }

        tableKit.view.refreshControl = refreshControl

        bag += tableKit.view.addTableHeaderView(Header(service: service), animated: false)

        let containerView = UIView()
        viewController.view = containerView

        containerView.addSubview(tableKit.view)

        tableKit.view.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

        bag += service.dataSignal.atOnce().compactMap { $0?.invitations }
            .onValue { invitations in
                var table = Table(sections: [
                    (
                        L10n.ReferralsActive.Invited.title,
                        invitations.map { InvitationRow(invitation: $0) }
                    )
                ])
                table.removeEmptySections()
                tableKit.set(table)
            }

        let shareButton = ShareButton()

        bag +=
            containerView.add(shareButton) { buttonView in
                buttonView.snp.makeConstraints { make in make.bottom.leading.trailing.equalToSuperview()
                }

                bag += buttonView.didLayoutSignal.onValue {
                    let bottomInset = buttonView.frame.height - buttonView.safeAreaInsets.bottom
                    tableKit.view.scrollIndicatorInsets = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: bottomInset,
                        right: 0
                    )
                    tableKit.view.contentInset = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: bottomInset,
                        right: 0
                    )
                }
            }
            .withLatestFrom(service.dataSignal.atOnce().compactMap { $0?.discountCode })
            .onValue { buttonView, discountCode in shareButton.loadableButton.startLoading()
                viewController.presentConditionally(
                    PushNotificationReminder(),
                    style: .detented(.large)
                )
                .onResult { _ in
                    let encodedDiscountCode =
                        discountCode.addingPercentEncoding(
                            withAllowedCharacters: .urlQueryAllowed
                        ) ?? ""
                    let activity = ActivityView(
                        activityItems: [
                            URL(string: L10n.referralsLink(encodedDiscountCode)) ?? ""
                        ],
                        applicationActivities: nil,
                        sourceView: buttonView,
                        sourceRect: buttonView.bounds
                    )
                    viewController.present(activity)
                    shareButton.loadableButton.stopLoading()
                }
            }

        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .forever))

        return (viewController, bag)
    }
}
