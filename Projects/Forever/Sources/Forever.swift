import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

@available(iOS 16.0, *)
public struct ForeverView: View {
    @PresentableStore var store: ForeverStore
    @State var scrollTo: Int = -1
    @State var spacing: CGFloat = 0
    @State var totalHeight: CGFloat = 0
    @State var discountCodeHeight: CGFloat = 0 {
        didSet {
            recalculateHeight()
        }
    }
    @State var headerHeight: CGFloat = 0 {
        didSet {
            recalculateHeight()
        }
    }

    @StateObject private var pathState = MyModelObject()

    public init() {}

    public var body: some View {
        NavigationStack(path: $pathState.path) {

            LoadingViewWithContent(ForeverStore.self, [.fetchForeverData], [.fetch]) {
                ScrollViewReader { value in
                    hForm {
                        VStack(spacing: 0) {
                            HeaderView {
                                scrollTo = 2
                            }
                            .id(0)
                            .padding(.bottom, 16)
                            .background(
                                GeometryReader(content: { proxy in
                                    Color.clear
                                        .onAppear {
                                            print(proxy.size)
                                            headerHeight = proxy.size.height
                                        }
                                        .onChange(of: proxy.size) { size in
                                            print(proxy.size)
                                            headerHeight = size.height
                                        }
                                })
                            )
                            Spacing(height: Float(spacing))
                            DiscountCodeSectionView().id(1)
                                .navigationDestination(for: NavigationForeverView.self) { view in
                                    let _ = pathState.changeForeverRoute(view)
                                    pathState.getForeverView(pathState: pathState)
                                }
                                .background(
                                    GeometryReader(content: { proxy in
                                        Color.clear
                                            .onAppear {
                                                print(proxy.size)
                                                discountCodeHeight = proxy.size.height
                                            }
                                            .onChange(of: proxy.size) { size in
                                                print(proxy.size)
                                                discountCodeHeight = size.height
                                            }
                                    })
                                )
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
                .onPullToRefresh {
                    await store.sendAsync(.fetch)
                }
            }
            .background(
                GeometryReader(content: { proxy in
                    Color.clear
                        .onAppear {
                            print(proxy.size)
                            totalHeight = proxy.size.height
                        }
                        .onChange(of: proxy.size) { size in
                            print(proxy.size)
                            totalHeight = size.height
                        }
                })
            )
            //            .sheet(isPresented: pathState.$showSheet) {
            //                pathState.getForeverView(pathState: pathState)
            //            }
        }
    }

    private func recalculateHeight() {
        spacing = max(totalHeight - discountCodeHeight - headerHeight, 0)
    }
}

@available(iOS 16.0, *)
extension ForeverView {
    @available(iOS 16.0, *)
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
        .configureTabBarItem(
            title: L10n.tabReferralsTitle,
            image: hCoreUIAssets.foreverTab.image,
            selectedImage: hCoreUIAssets.foreverTabActive.image
        )
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
        if #available(iOS 16.0, *) {
            return ForeverView()
                .onAppear {
                    Dependencies.shared.add(module: Module { () -> ForeverService in ForeverServiceDemo() })
                }
        } else {
            // Fallback on earlier versions
            return EmptyView()
        }
    }
}

@available(iOS 16.0, *)
extension MyModelObject {
    @ViewBuilder
    public func getForeverView(pathState: MyModelObject) -> some View {
        switch currentForeverRoute {
        case .changeCodeView:
            //            hText("testing")
            //                .sheet(isPresented: .constant(true)) {
            ChangeCodeView()
        //                        .presentationDetents([.medium])
        //                }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}
