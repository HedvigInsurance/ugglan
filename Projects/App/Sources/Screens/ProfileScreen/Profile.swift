import Apollo
import Flow
import Form
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct Profile { @Inject var client: ApolloClient }

extension Profile: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let bag = DisposeBag()

		let viewController = UIViewController()
		viewController.displayableTitle = L10n.profileTitle
		viewController.installChatButton()

		let form = FormView()

		let profileSection = ProfileSection(presentingViewController: viewController)

		bag += form.append(profileSection)

		bag += form.append(Spacing(height: 20))

		let settingsSection = SettingsSection(presentingViewController: viewController)
		bag += form.append(settingsSection)

		form.appendSpacing(.custom(20))

		let query = GraphQL.ProfileQuery()

		bag += client.watch(query: query).bindTo(profileSection.dataSignal)

		bag += viewController.install(form) { scrollView in
			let refreshControl = UIRefreshControl()
			bag += self.client.refetchOnRefresh(query: query, refreshControl: refreshControl)

			scrollView.refreshControl = refreshControl
			bag += scrollView.chainAllControlResponders(shouldLoop: true, returnKey: .next)
		}

		return (viewController, bag)
	}
}

extension Profile: Tabable {
	func tabBarItem() -> UITabBarItem {
		UITabBarItem(
			title: L10n.tabProfileTitle,
			image: Asset.profileTab.image,
			selectedImage: Asset.profileTabActive.image
		)
	}
}
