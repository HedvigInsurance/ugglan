import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import WatchConnectivity
import hCore
import hGraphQL

struct KeyGearOverview {
    @Inject var client: ApolloClient

    func autoAddDevices(viewController: UIViewController) {
        if WCSession.isSupported() {
            let bag = DisposeBag()
            let session = WCSession.default
            let coordinator = Coordinator { bag.dispose() }
            bag.hold(coordinator)
            session.delegate = coordinator

            session.activate()

            class Coordinator: NSObject, WCSessionDelegate {
                let onDone: () -> Void
                @Inject var client: ApolloClient

                init(onDone: @escaping () -> Void) { self.onDone = onDone }

                func session(
                    _ session: WCSession,
                    activationDidCompleteWith _: WCSessionActivationState,
                    error _: Error?
                ) {
                    if session.isPaired {
                        let bag = DisposeBag()

                        bag += client.fetch(query: GraphQL.MemberIdQuery()).valueSignal
                            .compactMap { $0.member.id }
                            .onValue { memberId in
                                bag += self.client
                                    .perform(
                                        mutation:
                                            GraphQL
                                            .CreateKeyGearItemMutation(
                                                input:
                                                    GraphQL
                                                    .CreateKeyGearItemInput(
                                                        photos: [],
                                                        category:
                                                            .smartWatch,
                                                        physicalReferenceHash:
                                                            "apple-watch-\(memberId)"
                                                    )
                                            )
                                    )
                                    .valueSignal
                                    .compactMap { $0.createKeyGearItem.id }
                                    .onValue { itemId in
                                        self.client
                                            .perform(
                                                mutation:
                                                    GraphQL
                                                    .UpdateKeyGearItemNameMutation(
                                                        id:
                                                            itemId,
                                                        name:
                                                            "Apple Watch"
                                                    )
                                            )
                                            .onValue { _ in
                                                self.client
                                                    .fetch(
                                                        query:
                                                            GraphQL
                                                            .KeyGearItemsQuery(),
                                                        cachePolicy:
                                                            .fetchIgnoringCacheData
                                                    )
                                                    .onValue { _ in
                                                    }
                                                bag.dispose()
                                            }
                                    }
                            }
                    }

                    onDone()
                }

                func sessionDidBecomeInactive(_: WCSession) {}

                func sessionDidDeactivate(_: WCSession) {}
            }
        }

        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else { return }

        let bag = DisposeBag()

        let category: GraphQL.KeyGearItemCategory =
            viewController.traitCollection.userInterfaceIdiom == .pad ? .tablet : .phone

        bag +=
            client.perform(
                mutation: GraphQL.CreateKeyGearItemMutation(
                    input: GraphQL.CreateKeyGearItemInput(
                        photos: [],
                        category: category,
                        physicalReferenceHash: deviceId
                    )
                )
            )
            .valueSignal.compactMap { $0.createKeyGearItem.id }
            .onValue { itemId in
                self.client
                    .perform(
                        mutation: GraphQL.UpdateKeyGearItemNameMutation(
                            id: itemId,
                            name: UIDevice.current.name
                        )
                    )
                    .onValue { _ in
                        self.client
                            .fetch(
                                query: GraphQL.KeyGearItemsQuery(),
                                cachePolicy: .fetchIgnoringCacheData
                            )
                            .onValue { _ in }
                        bag.dispose()
                    }
            }
    }
}

extension KeyGearOverview: Presentable {
    class KeyGearOverviewViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let split = UISplitViewController()
        bag += split.view.traitCollectionSignal.atOnce()
            .onValue { trait in
                split.preferredDisplayMode = trait.userInterfaceIdiom == .pad ? .allVisible : .automatic
            }

        split.view.backgroundColor = .brand(.primaryBackground())
        split.extendedLayoutIncludesOpaqueBars = true

        let viewController = KeyGearOverviewViewController()
        viewController.title = L10n.keyGearTabTitle

        bag += split.present(viewController, options: [.defaults, .showInMaster, .prefersLargeTitles(true)])

        autoAddDevices(viewController: split)

        let detailBag = DisposeBag()
        bag += detailBag

        if split.traitCollection.userInterfaceIdiom == .pad {
            let placeholder = UIViewController()
            placeholder.view.backgroundColor = .brand(.primaryBackground())
            detailBag += split.present(placeholder, options: [.defaults])
        }

        func presentDetail(id: String) {
            detailBag.dispose()

            if split.traitCollection.userInterfaceIdiom == .pad {
                detailBag += viewController.present(
                    KeyGearItem(id: id),
                    style: .default,
                    options: [.defaults, .largeTitleDisplayMode(.never), .autoPop, .unanimated]
                )
            } else {
                detailBag += viewController.present(
                    KeyGearItem(id: id),
                    style: .default,
                    options: [.defaults, .largeTitleDisplayMode(.never), .autoPop]
                )
            }
        }

        bag +=
            viewController.install(KeyGearListCollection()) { collectionView in
                //				let refreshControl = UIRefreshControl()
                //				bag += client.refetchOnRefresh(
                //					query: GraphQL.KeyGearItemsQuery(),
                //					refreshControl: refreshControl
                //				)
                //
                //				collectionView.refreshControl = refreshControl

            }
            .onValue { result in
                switch result {
                case .add:
                    viewController.present(AddKeyGearItem(), style: .modally())
                        .onValue { id in presentDetail(id: id) }
                case let .row(id): presentDetail(id: id)
                }
            }

        return (split, bag)
    }
}

extension KeyGearOverview: Tabable {
    func tabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: L10n.keyGearTabTitle,
            image: Asset.keyGearTabIcon.image,
            selectedImage: Asset.keyGearTabIcon.image
        )
    }
}
