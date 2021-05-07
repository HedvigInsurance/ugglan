import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

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

		bag += service.dataSignal.atOnce().compactMap { $0?.invitations }.onValue { invitations in
			var table = Table(sections: [
				(L10n.ReferralsActive.Invited.title, invitations.map { InvitationRow(invitation: $0) })
			])
			table.removeEmptySections()
			tableKit.set(table)
		}

		if Localization.Locale.currentLocale.market == .no {
			bag += tableKit.view.hasWindowSignal.filter(predicate: { $0 }).take(first: 1).onValue { _ in
				let defaultsKey = "hasShownInvitation"
				let hasShownInvitation = UserDefaults.standard.bool(forKey: defaultsKey)

				if !hasShownInvitation {
					viewController.present(
						InvitationScreen(
							potentialDiscountAmountSignal: self.service.dataSignal.map {
								$0?.potentialDiscountAmount
							}
						),
						style: .detented(.large)
					).onResult { _ in UserDefaults.standard.set(true, forKey: defaultsKey)
						UserDefaults.standard.synchronize()
					}
				}
			}
		}

		let shareButton = ShareButton()

		bag += containerView.add(shareButton) { buttonView in
			buttonView.snp.makeConstraints { make in make.bottom.leading.trailing.equalToSuperview() }

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
		}.withLatestFrom(service.dataSignal.atOnce().compactMap { $0?.discountCode }).onValue {
			buttonView,
			discountCode in shareButton.loadableButton.startLoading()
			viewController.presentConditionally(PushNotificationReminder(), style: .detented(.large))
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

		return (viewController, bag)
	}
}

extension Forever: Tabable {
	public func tabBarItem() -> UITabBarItem {
		UITabBarItem(title: L10n.tabReferralsTitle, image: Asset.tab.image, selectedImage: Asset.tab.image)
	}
}
