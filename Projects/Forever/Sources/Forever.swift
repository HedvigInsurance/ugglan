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
            HeaderView()
            DiscountCodeSectionView()
            InvitationTable()
            //DiscountCodeRepresentable(service: ForeverServiceGraphQL()).frame(height: 200).padding().border(.black)
        }
    }
}

public enum ForeverResult {
    case dummy
}

extension ForeverView {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: ForeverResult) -> ResultJourney
    ) -> some JourneyPresentation {
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
            }
        }
        .configureTitle(L10n.referralsScreenTitle)
        .configureForeverTabBarItem
        /*.addConfiguration({ presenter in
            // - TODO - refactor
            let tabBarItem = UITabBarItem(
                title: L10n.tabReferralsTitle,
                image: Asset.tab.image,
                selectedImage: Asset.tabActive.image
            )
            presenter.viewController.tabBarItem = tabBarItem
        })*/
    }
}

public struct DiscountCodeRepresentable: UIViewRepresentable {
    let service: ForeverService

    public class Coordinator {
        let bag = DisposeBag()
        let discountView: DiscountCodeSection

        init(
            service: ForeverService
        ) {
            self.discountView = DiscountCodeSection(service: service)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(service: service)
    }

    public func makeUIView(context: Context) -> some UIView {
        let (view, disposable) = context.coordinator.discountView.materialize(
            events: ViewableEvents(wasAddedCallbacker: .init())
        )
        //let (view, disposable) = context.coordinator.headerView.materialize(
        //    events: ViewableEvents(wasAddedCallbacker: .init())
        //)
        context.coordinator.bag += DisposeOnMain(disposable)
        //print("GRADZ height:", dynamicHeight, view.sizeThatFits(view.bounds.size).height)
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        /*uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        DispatchQueue.main.async {
            dynamicHeight =
                uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            print("GRADZ height:", dynamicHeight, uiView.sizeThatFits(uiView.bounds.size).height)
        }*/
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
